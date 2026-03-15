import 'package:flutter/material.dart';

class DashboardField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isNum;
  final bool enabled;

  const DashboardField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isNum = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFF161616) : Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        style: TextStyle(
          color: enabled ? Colors.white : Colors.white54,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: Icon(
            icon,
            size: 20,
            color: enabled ? Colors.white54 : Colors.white24,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class DashboardAutocompleteField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final List<String> options;

  const DashboardAutocompleteField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return options.where((String option) {
          return option.contains(textEditingValue.text.toUpperCase());
        });
      },
      onSelected: (String selection) {
        controller.text = selection;
      },
      fieldViewBuilder: (context, fieldCtrl, focusNode, onFieldSubmitted) {
        if (controller.text.isNotEmpty && fieldCtrl.text.isEmpty) {
          fieldCtrl.text = controller.text;
        }
        fieldCtrl.addListener(() {
          controller.text = fieldCtrl.text.toUpperCase();
        });

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: TextField(
            controller: fieldCtrl,
            focusNode: focusNode,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
              prefixIcon: Icon(icon, size: 20, color: Colors.white38),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              border: InputBorder.none,
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: MediaQuery.of(context).size.width - 48,
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return ListTile(
                    title: Text(
                      option,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class DashboardFormSection extends StatelessWidget {
  final String title;
  const DashboardFormSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class KeeperBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isAction;
  final VoidCallback? onTap;

  const KeeperBox({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isAction = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isAction ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isAction ? Colors.white : Colors.white70,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isAction && value.contains('Pilih') ? Colors.white54 : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (isAction)
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white70,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardEmptyState extends StatelessWidget {
  final String title;
  final String sub;
  final IconData icon;
  final String btnText;
  final VoidCallback onTap;

  const DashboardEmptyState({
    super.key,
    required this.title,
    required this.sub,
    required this.icon,
    required this.btnText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white24, size: 64),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onTap,
              child: Text(
                btnText,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
