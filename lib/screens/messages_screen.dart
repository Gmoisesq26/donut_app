import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController nombreController = TextEditingController();

  final TextEditingController mensajeController = TextEditingController();

  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool isSaving = false;

  // REGISTRAR MENSAJE
  Future<void> guardarMensaje() async {
    final user = auth.currentUser;

    if (user == null) {
      mostrarMensaje('Debes iniciar sesión primero');
      return;
    }

    final nombre = nombreController.text.trim();
    final mensaje = mensajeController.text.trim();

    if (nombre.isEmpty || mensaje.isEmpty) {
      mostrarMensaje('Completa todos los campos');
      return;
    }

    if (nombre.length > 50 || mensaje.length > 2000) {
      mostrarMensaje('El texto supera el límite permitido');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await db.collection('mensajes').add({
        'userId': user.uid,
        'nombre': nombre,
        'mensaje': mensaje,
        'fecha': FieldValue.serverTimestamp(),
      });

      nombreController.clear();
      mensajeController.clear();

      FocusScope.of(context).unfocus();

      mostrarMensaje('Mensaje guardado correctamente');
    } on FirebaseException catch (e) {
      mostrarMensaje('Error de Firebase: ${e.message}');
    } catch (e) {
      mostrarMensaje('Ocurrió un error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ELIMINAR MENSAJE
  Future<void> eliminarMensaje(String documentoId) async {
    try {
      await db.collection('mensajes').doc(documentoId).delete();
      mostrarMensaje('Mensaje eliminado');
    } catch (e) {
      mostrarMensaje('No se pudo eliminar el mensaje');
    }
  }

  // CERRAR SESIÓN
  Future<void> cerrarSesion() async {
    await auth.signOut();

    if (!mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // NOTIFICACIONES
  void mostrarMensaje(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    mensajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Inicia sesión primero'),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Mis mensajes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: cerrarSesion,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // DETECTAR SI EL TECLADO ESTÁ ABIERTO
            final tecladoAbierto = MediaQuery.of(context).viewInsets.bottom > 0;

            return Column(
              children: [
                // FORMULARIO
                Expanded(
                  flex: tecladoAbierto ? 1 : 0,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Registrar un mensaje',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: nombreController,
                          maxLength: 50,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            hintText: 'Escribe tu nombre',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: mensajeController,
                          maxLength: 2000,
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            labelText: 'Mensaje',
                            hintText: 'Escribe tu mensaje',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.message),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: isSaving ? null : guardarMensaje,
                          icon: isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            isSaving ? 'Guardando...' : 'Guardar mensaje',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // OCULTAR LISTA MIENTRAS APARECE EL TECLADO
                if (!tecladoAbierto) ...[
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Mensajes registrados',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: db
                          .collection('mensajes')
                          .where(
                            'userId',
                            isEqualTo: user.uid,
                          )
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Error al cargar los mensajes',
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final mensajes = snapshot.data!.docs;

                        if (mensajes.isEmpty) {
                          return const Center(
                            child: Text(
                              'Todavía no tienes mensajes registrados',
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          itemCount: mensajes.length,
                          itemBuilder: (context, index) {
                            final documento = mensajes[index];
                            final data = documento.data();

                            return Card(
                              margin: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Text(
                                  data['nombre'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  data['mensaje'] ?? '',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    eliminarMensaje(documento.id);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
