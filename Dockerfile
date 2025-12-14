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
    --url https://civitai.com/models/2086389/uncanny-photorealism-chroma?modelVersionId=2420275

Loras:
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


# Cleanup
RUN rm -rf /tmp/civitai


# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/
