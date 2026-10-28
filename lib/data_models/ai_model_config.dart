class AiModelConfig {
  static const String idSmolLm2 = 'smollm2_360m';
  static const String idQwen25HalfB = 'qwen25_0_5b';
  static const String idLlama32OneB = 'llama32_1b';
  static const String idQwen25OneHalfB = 'qwen25_1_5b';
  static const String idLlama32ThreeB = 'llama32_3b';
  static const String idCustom = 'custom_gguf';

  static const List<String> allModelIds = [
    idSmolLm2,
    idQwen25HalfB,
    idLlama32OneB,
    idQwen25OneHalfB,
    idLlama32ThreeB,
    idCustom,
  ];

  final String id;
  final String displayName;
  final String defaultFileName;
  final String? downloadUrl;
  final String? customFilePath;
  final bool isCustom;

  const AiModelConfig({
    required this.id,
    required this.displayName,
    required this.defaultFileName,
    this.downloadUrl,
    this.customFilePath,
    this.isCustom = false,
  });

  const AiModelConfig.smolLm2()
      : id = idSmolLm2,
        displayName = 'SmolLM2 360M Instruct',
        defaultFileName = 'smollm2-360m-instruct-q8_0.gguf',
        downloadUrl =
            'https://huggingface.co/HuggingFaceTB/SmolLM2-360M-Instruct-GGUF/resolve/main/smollm2-360m-instruct-q8_0.gguf',
        customFilePath = null,
        isCustom = false;

  const AiModelConfig.qwen25HalfB()
      : id = idQwen25HalfB,
        displayName = 'Qwen 2.5 0.5B Instruct',
        defaultFileName = 'qwen2.5-0.5b-instruct-q4_k_m.gguf',
        downloadUrl =
            'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf',
        customFilePath = null,
        isCustom = false;

  const AiModelConfig.llama32OneB()
      : id = idLlama32OneB,
        displayName = 'Llama 3.2 1B Instruct',
        defaultFileName = 'llama-3.2-1b-instruct-q4_k_m.gguf',
        downloadUrl =
            'https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf',
        customFilePath = null,
        isCustom = false;

  const AiModelConfig.qwen25OneHalfB()
      : id = idQwen25OneHalfB,
        displayName = 'Qwen 2.5 1.5B Instruct',
        defaultFileName = 'qwen2.5-1.5b-instruct-q4_k_m.gguf',
        downloadUrl =
            'https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf',
        customFilePath = null,
        isCustom = false;

  const AiModelConfig.llama32ThreeB()
      : id = idLlama32ThreeB,
        displayName = 'Llama 3.2 3B Instruct',
        defaultFileName = 'llama-3.2-3b-instruct-q4_k_m.gguf',
        downloadUrl =
            'https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf',
        customFilePath = null,
        isCustom = false;

  const AiModelConfig.custom({
    required String filePath,
  })  : id = idCustom,
        displayName = 'Custom GGUF',
        defaultFileName = filePath,
        downloadUrl = null,
        customFilePath = filePath,
        isCustom = true;

  static AiModelConfig resolve({
    required String selectedId,
    String? customPath,
  }) {
    switch (selectedId) {
      case idSmolLm2:
        return const AiModelConfig.smolLm2();
      case idLlama32OneB:
        return const AiModelConfig.llama32OneB();
      case idQwen25OneHalfB:
        return const AiModelConfig.qwen25OneHalfB();
      case idLlama32ThreeB:
        return const AiModelConfig.llama32ThreeB();
      case idCustom:
        if (customPath != null && customPath.trim().isNotEmpty) {
          return AiModelConfig.custom(filePath: customPath.trim());
        }
        return const AiModelConfig.qwen25HalfB();
      case idQwen25HalfB:
      default:
        return const AiModelConfig.qwen25HalfB();
    }
  }
}
