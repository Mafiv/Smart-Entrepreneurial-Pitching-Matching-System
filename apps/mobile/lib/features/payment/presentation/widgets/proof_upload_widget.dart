import 'package:flutter/material.dart';

class ProofUploadWidget extends StatefulWidget {
  final String milestoneId;
  final bool isLoading;
  final Function(Map<String, dynamic>) onSubmit;

  const ProofUploadWidget({
    Key? key,
    required this.milestoneId,
    required this.isLoading,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<ProofUploadWidget> createState() => _ProofUploadWidgetState();
}

class _ProofUploadWidgetState extends State<ProofUploadWidget> {
  final List<String> _uploadedFiles = [];
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _addFile() {
    // Simulated file addition (in real app, use file_picker or image_picker)
    // For now, just show a dialog allowing users to enter file info
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add File'),
        content: const Text(
            'File upload would be implemented here with file_picker'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Simulate adding a file
              setState(() {
                _uploadedFiles.add(
                    'document_${DateTime.now().millisecondsSinceEpoch}.pdf');
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File added')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeFile(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
    });
  }

  void _submitProof() {
    if (_uploadedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one file'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final proofData = {
      'documents': _uploadedFiles,
      'description': _descriptionController.text,
    };

    widget.onSubmit(proofData);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description Text Field
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: 'Describe the proof of completion',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          maxLines: 3,
          maxLength: 500,
        ),
        const SizedBox(height: 16),

        // Files List
        if (_uploadedFiles.isNotEmpty) ...[
          const Text(
            'Uploaded Files',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            _uploadedFiles.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.attach_file,
                            size: 20,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _uploadedFiles[index],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => _removeFile(index),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Add File Button
        OutlinedButton.icon(
          onPressed: widget.isLoading ? null : _addFile,
          icon: const Icon(Icons.add),
          label: const Text('Add File'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
        const SizedBox(height: 16),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: widget.isLoading ? null : _submitProof,
            icon: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.upload),
            label: const Text('Submit Proof'),
          ),
        ),
      ],
    );
  }
}
