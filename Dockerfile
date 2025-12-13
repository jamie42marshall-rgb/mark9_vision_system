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
# RUN # Could not find URL for uncannyPhotorealism_v10.safetensors
RUN comfy model download --url https://huggingface.co/silveroxides/flan-t5-xxl-encoder-only/blob/main/flan-t5-xxl-fp16.safetensors --relative-path models/text_encoders --filename flan-t5-xxl-fp16.safetensors
RUN comfy model download --url https://huggingface.co/Comfy-Org/Lumina_Image_2.0_Repackaged/resolve/main/split_files/vae/ae.safetensors --relative-path models/vae --filename ae.safetensors
RUN comfy model download --url https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt --relative-path models/ultralytics/bbox --filename face_yolov8m.pt
# RUN # Could not find URL for 4xNomosWebPhoto_RealPLKSR.safetensors

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/
