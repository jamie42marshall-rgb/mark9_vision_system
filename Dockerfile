# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.0-base

# install custom nodes into comfyui
RUN comfy node install --exit-on-fail comfyui-impact-pack@8.28.0
RUN comfy node install --exit-on-fail comfyui_ultimatesdupscale@1.6.0
RUN comfy node install --exit-on-fail rgthree-comfy@1.0.2512112053
RUN comfy node install --exit-on-fail RES4LYF
RUN comfy node install --exit-on-fail comfyui-impact-subpack@1.3.5
RUN comfy node install --exit-on-fail comfyui-custom-scripts@1.2.5

# download models into comfyui
RUN comfy model download --url https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth --relative-path models/checkpoints --filename sam_vit_b_01ec64.pth
RUN comfy model download --url https://huggingface.co/silveroxides/flan-t5-xxl-encoder-only/resolve/main/flan-t5-xxl-fp16.safetensors --relative-path models/text_encoders --filename flan-t5-xxl-fp16.safetensors
RUN comfy model download --url https://huggingface.co/Comfy-Org/Lumina_Image_2.0_Repackaged/resolve/main/split_files/vae/ae.safetensors --relative-path models/vae --filename ae.safetensors
RUN comfy model download --url https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt --relative-path models/ultralytics/bbox --filename face_yolov8m.pt


# RUN # Could not find URL for 4xNomosWebPhoto_RealPLKSR.safetensors
# Add the upscaler
RUN comfy model download \
    --url https://huggingface.co/Phips/4xNomosWebPhoto_RealPLKSR/resolve/main/4xNomosWebPhoto_RealPLKSR.safetensors \
    --relative-path models/upscale_models \
    --filename 4xNomosWebPhoto_RealPLKSR.safetensors


RUN git clone https://github.com/deepratna-awale/CivitAI-Model-Downloader.git /tmp/civitai && \
    pip install -r /tmp/civitai/requirements.txt


# RUN # Could not find URL for uncannyPhotorealism_v10.safetensors
RUN cd /tmp/civitai && python download.py \
    --sd /comfyui \
    --api-key aae9ce012e1d88cbc7bcf0bb38f0eafe \
    --url https://civitai.com/models/2086389?modelVersionId=2360624

#Loras:
#analog dreams lora  "qsbrtuysk"
RUN cd /tmp/civitai && python download.py \
    --sd /comfyui \
    --api-key aae9ce012e1d88cbc7bcf0bb38f0eafe \
    --url https://civitai.com/models/2162499/analog-dreams?modelVersionId=2435339

# prof photo lora
RUN cd /tmp/civitai && python download.py \
    --sd /comfyui \
    --api-key aae9ce012e1d88cbc7bcf0bb38f0eafe \
    --url https://civitai.com/models/1908534?modelVersionId=2271596

#lenovo lora
RUN cd /tmp/civitai && python download.py \
    --sd /comfyui \
    --api-key aae9ce012e1d88cbc7bcf0bb38f0eafe \
    --url https://civitai.com/models/1662740/lenovo-ultrareal?modelVersionId=2299345

RUN echo "=========================================" && \
    echo "COMPLETE MODEL DIRECTORY INVENTORY" && \
    echo "=========================================" && \
    echo "" && \
    echo "=== CHECKPOINTS (SDXL/SD models) ===" && \
    ls -lah /comfyui/models/checkpoints/ 2>/dev/null || echo "Directory not found" && \
    echo "" && \
    echo "=== UNET (Flux/Lumina diffusion models) ===" && \
    ls -lah /comfyui/models/unet/ 2>/dev/null || echo "Directory not found" && \
    echo "" && \
    echo "=== DIFFUSION_MODELS ===" && \
    ls -lah /comfyui/models/diffusion_models/ 2>/dev/null || echo "Directory not found" && \
    echo "" && \
    echo "=== LORA ===" && \
    ls -lah /comfyui/models/lora/ 2>/dev/null || echo "Directory not found" && \
    echo "" && \
    echo "=== TEXT_ENCODERS (CLIP/T5) ===" && \
    ls -lah /comfyui/models/text_encoders/ 2>/dev/null || echo "Directory not found" && \
    echo "" && \
    echo "=== CLIP ===" && \
    ls -lah /comfyui/models/clip/ 2>/dev/null || echo "Directory not found" && \
    echo "" && \
    echo "=== VAE ===" && \
    ls -lah /comfyui/models/vae/ 2>/dev/null || echo "Directory not found" && \
    echo "" && \
    echo "=== UPSCALE_MODELS ===" && \
    ls -lah /comfyui/models/upscale_models/ 2>/dev/null || echo "Directory not found" && \
    echo "" && \
    echo "=== CONTROLNET ===" && \
    ls -lah /comfyui/models/controlnet/ 2>/dev/null || echo "Directory not found" && \
    echo "" && \
    echo "=== EMBEDDINGS ===" && \
    ls -lah /comfyui/embeddings/ 2>/dev/null || echo "Directory not found" && \
    echo "" && \
    echo "=== ULTRALYTICS ===" && \
    ls -lah /comfyui/models/ultralytics/bbox/ 2>/dev/null || echo "Directory not found" && \
    ls -lah /comfyui/models/ultralytics/segm/ 2>/dev/null || echo "Directory not found" && \
    echo "" && \
    echo "=== SAMS ===" && \
    ls -lah /comfyui/models/sams/ 2>/dev/null || echo "Directory not found" && \
    echo "" && \
    echo "========================================="

# Cleanup
RUN rm -rf /tmp/civitai


# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/
