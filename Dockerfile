# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.0-base

# === H100 GPU OPTIMIZATIONS ===
# Modify start.sh to support COMFY_EXTRA_ARGS environment variable
# Check both possible locations and modify whichever exists
RUN if [ -f /start.sh ]; then \
        sed -i 's|--log-stdout &|--log-stdout ${COMFY_EXTRA_ARGS} \&|g' /start.sh && \
        echo 'echo "=== DEBUG: start.sh ComfyUI launch commands ==="' >> /start.sh && \
        echo 'grep "python.*main.py" /start.sh | head -2' >> /start.sh && \
        echo 'echo "=== COMFY_EXTRA_ARGS = ${COMFY_EXTRA_ARGS} ==="' >> /start.sh && \
        echo 'echo "=== END DEBUG ==="' >> /start.sh; \
    elif [ -f /src/start.sh ]; then \
        sed -i 's|--log-stdout &|--log-stdout ${COMFY_EXTRA_ARGS} \&|g' /src/start.sh && \
        echo 'echo "=== DEBUG: start.sh ComfyUI launch commands ==="' >> /src/start.sh && \
        echo 'grep "python.*main.py" /src/start.sh | head -2' >> /src/start.sh && \
        echo 'echo "=== COMFY_EXTRA_ARGS = ${COMFY_EXTRA_ARGS} ==="' >> /src/start.sh && \
        echo 'echo "=== END DEBUG ==="' >> /src/start.sh; \
    else \
        echo "ERROR: Could not find start.sh"; \
        exit 1; \
    fi

# Force cache bust for curl installation
ARG CACHEBUST=1

# install custom nodes into comfyui
RUN comfy node install --exit-on-fail comfyui-impact-pack@8.28.0
RUN comfy node install --exit-on-fail comfyui_ultimatesdupscale@1.6.0
RUN comfy node install --exit-on-fail rgthree-comfy@1.0.2512112053
RUN comfy node install --exit-on-fail RES4LYF
RUN comfy node install --exit-on-fail comfyui-impact-subpack@1.3.5
RUN comfy node install --exit-on-fail comfyui-custom-scripts@1.2.5

# Install curl for CivitAI downloads
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# === DOWNLOAD CIVITAI MODELS FIRST (fail fast if these break) ===
# Create directories for CivitAI models
RUN mkdir -p /comfyui/models/unet /comfyui/models/loras

# Download uncanny photorealism checkpoint via CivitAI API (using curl)
RUN echo "Downloading uncannyPhotorealism_v10..." && \
    curl -L -H "Authorization: Bearer aae9ce012e1d88cbc7bcf0bb38f0eafe" \
    "https://civitai.com/api/download/models/2360624?type=Model&format=SafeTensor" \
    -o /comfyui/models/unet/uncannyPhotorealism_v10.safetensors && \
    echo "Download complete!"

# Download all LoRAs via CivitAI API in one layer (faster builds)
RUN echo "Downloading all LoRAs..." && \
    curl -L -H "Authorization: Bearer aae9ce012e1d88cbc7bcf0bb38f0eafe" \
    "https://civitai.com/api/download/models/2435339?type=Model&format=SafeTensor" \
    -o /comfyui/models/loras/analog-dreams.safetensors && \
    echo "analog-dreams LoRA downloaded" && \
    curl -L -H "Authorization: Bearer aae9ce012e1d88cbc7bcf0bb38f0eafe" \
    "https://civitai.com/api/download/models/2271596?type=Model&format=SafeTensor" \
    -o /comfyui/models/loras/prof-photo.safetensors && \
    echo "prof-photo LoRA downloaded" && \
    curl -L -H "Authorization: Bearer aae9ce012e1d88cbc7bcf0bb38f0eafe" \
    "https://civitai.com/api/download/models/2299345?type=Model&format=SafeTensor" \
    -o /comfyui/models/loras/lenovo-ultrareal.safetensors && \
    echo "All LoRAs downloaded successfully!"

# === DOWNLOAD OTHER MODELS (after CivitAI models) ===
RUN comfy model download --url https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth --relative-path models/checkpoints --filename sam_vit_b_01ec64.pth
RUN comfy model download --url https://huggingface.co/silveroxides/flan-t5-xxl-encoder-only/resolve/main/flan-t5-xxl-fp16.safetensors --relative-path models/text_encoders --filename flan-t5-xxl-fp16.safetensors
RUN comfy model download --url https://huggingface.co/Comfy-Org/Lumina_Image_2.0_Repackaged/resolve/main/split_files/vae/ae.safetensors --relative-path models/vae --filename ae.safetensors
RUN comfy model download --url https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt --relative-path models/ultralytics/bbox --filename face_yolov8m.pt

# Add the upscaler
RUN comfy model download \
    --url https://huggingface.co/Phips/4xNomosWebPhoto_RealPLKSR/resolve/main/4xNomosWebPhoto_RealPLKSR.safetensors \
    --relative-path models/upscale_models \
    --filename 4xNomosWebPhoto_RealPLKSR.safetensors

# === COMPREHENSIVE MODEL DIRECTORY DEBUG (commented out to speed up builds) ===
# Uncomment this section if you need to debug model locations
# RUN echo "=========================================" && \
#     echo "COMPLETE MODEL DIRECTORY INVENTORY" && \
#     echo "=========================================" && \
#     echo "" && \
#     echo "=== CHECKPOINTS (SDXL/SD models) ===" && \
#     ls -lah /comfyui/models/checkpoints/ 2>/dev/null || echo "Directory not found" && \
#     echo "" && \
#     echo "=== UNET (Flux/Lumina diffusion models) ===" && \
#     ls -lah /comfyui/models/unet/ 2>/dev/null || echo "Directory not found" && \
#     echo "" && \
#     echo "=== DIFFUSION_MODELS ===" && \
#     ls -lah /comfyui/models/diffusion_models/ 2>/dev/null || echo "Directory not found" && \
#     echo "" && \
#     echo "=== LORAS ===" && \
#     ls -lah /comfyui/models/loras/ 2>/dev/null || echo "Directory not found" && \
#     echo "" && \
#     echo "=== TEXT_ENCODERS (CLIP/T5) ===" && \
#     ls -lah /comfyui/models/text_encoders/ 2>/dev/null || echo "Directory not found" && \
#     echo "" && \
#     echo "=== CLIP ===" && \
#     ls -lah /comfyui/models/clip/ 2>/dev/null || echo "Directory not found" && \
#     echo "" && \
#     echo "=== VAE ===" && \
#     ls -lah /comfyui/models/vae/ 2>/dev/null || echo "Directory not found" && \
#     echo "" && \
#     echo "=== UPSCALE_MODELS ===" && \
#     ls -lah /comfyui/models/upscale_models/ 2>/dev/null || echo "Directory not found" && \
#     echo "" && \
#     echo "=== CONTROLNET ===" && \
#     ls -lah /comfyui/models/controlnet/ 2>/dev/null || echo "Directory not found" && \
#     echo "" && \
#     echo "=== EMBEDDINGS ===" && \
#     ls -lah /comfyui/embeddings/ 2>/dev/null || echo "Directory not found" && \
#     echo "" && \
#     echo "=== ULTRALYTICS ===" && \
#     ls -lah /comfyui/models/ultralytics/bbox/ 2>/dev/null || echo "Directory not found" && \
#     ls -lah /comfyui/models/ultralytics/segm/ 2>/dev/null || echo "Directory not found" && \
#     echo "" && \
#     echo "=== SAMS ===" && \
#     ls -lah /comfyui/models/sams/ 2>/dev/null || echo "Directory not found" && \
#     echo "" && \
#     echo "========================================="

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/
