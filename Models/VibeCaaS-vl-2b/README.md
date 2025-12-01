# VibeCaaS-vl:2b

**On-Device Vision Intelligence for VibeIntelligence**

Powered by VibeCaaS.com • A division of NeuralQuantum.ai LLC

---

## Overview

VibeCaaS-vl:2b is a lightweight, on-device vision-language model optimized for VibeIntelligence applications. Built on the Qwen3-VL architecture and enhanced with NeuralQuantum's optimizations, this model delivers exceptional visual understanding capabilities in a compact footprint.

## Key Features

- **Vision-Language Understanding**: Multimodal processing of images and text
- **On-Device Inference**: Optimized for local deployment via Ollama
- **Privacy-First**: All processing happens locally, no data leaves your device
- **Low Latency**: Fast inference suitable for real-time applications

## Capabilities

| Feature | Description |
|---------|-------------|
| Image Analysis | Describe and analyze visual content |
| OCR | Extract text from images |
| UI/UX Analysis | Provide design feedback |
| Object Detection | Identify objects and scenes |
| Creative Analysis | Art and design critique |

## Technical Specifications

| Specification | Value |
|--------------|-------|
| Base Model | Qwen2.5-VL |
| Parameters | ~2B |
| Context Length | 4096 tokens |
| Memory Required | ~4GB RAM |
| Supported Formats | JPEG, PNG, WebP |

## Installation

### Automatic (via VibeIntelligence)

1. Open VibeIntelligence
2. Go to Settings → AI Provider
3. Click "Setup" under "On-Device Vision"
4. Wait for installation to complete

### Manual

```bash
# Ensure Ollama is installed
brew install ollama

# Start Ollama server
ollama serve

# Pull the model directly from Ollama Hub
ollama run NeuroEquality/VibeCaaS-vl:2b
```

## Usage

### CLI

```bash
# Analyze an image
ollama run NeuroEquality/VibeCaaS-vl:2b "Describe this image" --image ./photo.jpg

# Extract text
ollama run NeuroEquality/VibeCaaS-vl:2b "Extract all text from this image" --image ./document.png
```

### API

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "NeuroEquality/VibeCaaS-vl:2b",
  "prompt": "Describe this image",
  "images": ["<base64_encoded_image>"]
}'
```

## License

Copyright © 2025 NeuralQuantum.ai LLC. All rights reserved.

For commercial licensing: hello@neuralquantum.ai

---

**Powered by VibeCaaS.com** | **Developed by NeuralQuantum.ai LLC**

