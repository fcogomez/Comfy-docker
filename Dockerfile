FROM pytorch/pytorch:2.5.1-cuda12.4-cudnn9-runtime

RUN apt update -y
RUN DEBIAN_FRONTEND=noninteractive TZ=America/Chicago apt install -y sudo build-essential iproute2 wget ncurses-bin figlet toilet vim nano tig curl git htop zsh ffmpeg tmux jq ca-certificates gnupg

RUN mkdir -p /etc/apt/keyrings

RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt update 
RUN apt install -y nodejs 

RUN cd /root && npm install request chokidar ws glob dotenv

RUN pip install opencv-python kornia loguru scikit-image onnx onnxruntime-gpu lpips ultralytics python_bidi arabic_reshaper 
RUN pip install torchvision gitpython timm addict yapf insightface numba

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
COPY ./.zshrc /root/.zshrc

WORKDIR  /workspace/

RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git /workspace/ComfyUI/custom_nodes/ComfyUI-Manager


WORKDIR /workspace
RUN cd /workspace/ComfyUI && pip install -r requirements.txt
RUN cd /workspace/ComfyUI/custom_nodes/ComfyUI-Manager && pip install -r requirements.txt

WORKDIR /workspace/ComfyUI/custom_nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Inspire-Pack.git && cd ComfyUI-Inspire-Pack && ( pip install -r requirements.txt || true )
RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git && cd ComfyUI-Impact-Pack && ( pip install -r requirements.txt || true ) 
RUN git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git && cd ComfyUI_IPAdapter_plus && ( pip install -r requirements.txt || true )
RUN git clone https://github.com/storyicon/comfyui_segment_anything.git && cd comfyui_segment_anything && ( pip install -r requirements.txt || true )
RUN git clone https://github.com/Gourieff/comfyui-reactor-node.git && cd comfyui-reactor-node && ( pip install -r requirements.txt || true )
RUN git clone https://github.com/WASasquatch/was-node-suite-comfyui.git && cd was-node-suite-comfyui && ( pip install -r requirements.txt || true )
RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git && cd ComfyUI-Custom-Scripts && ( pip install -r requirements.txt || true )
RUN git clone https://github.com/RockOfFire/ComfyUI_Comfyroll_CustomNodes.git && cd ComfyUI_Comfyroll_CustomNodes && ( pip install -r requirements.txt || true )
RUN git clone https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet && cd ComfyUI-Advanced-ControlNet && ( pip install -r requirements.txt || true )
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite && cd ComfyUI-VideoHelperSuite && ( pip install -r requirements.txt || true )
RUN git clone https://github.com/Fannovel16/comfyui_controlnet_aux && cd comfyui_controlnet_aux && ( pip install -r requirements.txt || true )
RUN git clone https://github.com/jags111/efficiency-nodes-comfyui && cd efficiency-nodes-comfyui && ( pip install -r requirements.txt || true )
RUN git clone https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git && cd ComfyUI-AnimateDiff-Evolved && ( pip install -r requirements.txt || true )
RUN git clone https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git && cd ComfyUI-Frame-Interpolation && ( python install.py || true )
RUN git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git --recursive 
RUN git clone https://github.com/mav-rik/facerestore_cf.git && cd facerestore_cf && ( pip install -r requirements.txt || true )
RUN git clone https://github.com/ManglerFTW/ComfyI2I.git && cd ComfyI2I && ( pip install -r requirements.txt || true )
RUN git clone https://github.com/BadCafeCode/masquerade-nodes-comfyui.git 
RUN git clone https://github.com/melMass/comfy_mtb.git && cd comfy_mtb && ( pip install -r requirements.txt || true )

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

RUN wget https://github.com/mikefarah/yq/releases/download/v4.45.1/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq

COPY ./extra_model_paths.yml /extra_model_paths.yml
COPY ./extra_downloads.yml /extra_downloads.yml

COPY ./run_comfy /bin/run_comfy
COPY ./.env /root/.env

RUN mv /opt/conda/bin/ffmpeg /opt/conda/bin/ffmpeg-ancient
RUN ln -s /usr/bin/ffmpeg /opt/conda/bin/ffmpeg
WORKDIR /workspace/ComfyUI

CMD ["/bin/run_comfy"]
