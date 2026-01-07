# TRELLIS.2 Docker Image
# Installs all dependencies for the TRELLIS.2 3D generation model
# Model weights are downloaded automatically on first run

FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

# Build arguments for versioning
ARG VERSION=dev
ARG BUILD_DATE
ARG VCS_REF

# OCI Image Labels
LABEL org.opencontainers.image.title="TRELLIS.2" \
      org.opencontainers.image.description="State-of-the-art 3D generative model for image-to-3D generation" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.source="https://github.com/microsoft/TRELLIS.2" \
      org.opencontainers.image.url="https://microsoft.github.io/TRELLIS.2" \
      org.opencontainers.image.documentation="https://github.com/microsoft/TRELLIS.2#readme" \
      org.opencontainers.image.vendor="Microsoft" \
      org.opencontainers.image.licenses="MIT"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set CUDA environment variables
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# Environment variables for TRELLIS.2
ENV OPENCV_IO_ENABLE_OPENEXR=1
ENV PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    curl \
    build-essential \
    cmake \
    ninja-build \
    libjpeg-dev \
    libpng-dev \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    libopenexr-dev \
    openexr \
    python3.10 \
    python3.10-dev \
    python3.10-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Upgrade pip
RUN python -m pip install --upgrade pip setuptools wheel

# Install PyTorch with CUDA 12.4 support
RUN pip install torch==2.6.0 torchvision==0.21.0 --index-url https://download.pytorch.org/whl/cu124

# Install basic Python dependencies
RUN pip install \
    imageio \
    imageio-ffmpeg \
    tqdm \
    easydict \
    opencv-python-headless \
    ninja \
    trimesh \
    transformers \
    gradio==6.0.1 \
    tensorboard \
    pandas \
    lpips \
    zstandard \
    numpy \
    plyfile \
    kornia \
    timm

# Install pillow-simd (optimized PIL)
RUN pip install pillow-simd

# Install utils3d from specific commit
RUN pip install git+https://github.com/EasternJournalist/utils3d.git@9a4eb15e4021b67b12c460c7057d642626897ec8

# Create extensions directory
WORKDIR /tmp/extensions

# Install flash-attn (for NVIDIA 80+ generation GPUs like A100, H100)
RUN pip install flash-attn==2.7.3 --no-build-isolation

# Install nvdiffrast
RUN git clone -b v0.4.0 https://github.com/NVlabs/nvdiffrast.git /tmp/extensions/nvdiffrast \
    && pip install /tmp/extensions/nvdiffrast --no-build-isolation

# Install nvdiffrec (split-sum PBR renderer)
RUN git clone -b renderutils https://github.com/JeffreyXiang/nvdiffrec.git /tmp/extensions/nvdiffrec \
    && pip install /tmp/extensions/nvdiffrec --no-build-isolation

# Install CuMesh
RUN git clone https://github.com/JeffreyXiang/CuMesh.git /tmp/extensions/CuMesh --recursive \
    && pip install /tmp/extensions/CuMesh --no-build-isolation

# Install FlexGEMM
RUN git clone https://github.com/JeffreyXiang/FlexGEMM.git /tmp/extensions/FlexGEMM --recursive \
    && pip install /tmp/extensions/FlexGEMM --no-build-isolation

# Set working directory
WORKDIR /app

# Copy TRELLIS.2 source code
COPY . /app/

# Install o-voxel from local copy
RUN pip install /app/o-voxel --no-build-isolation

# Clean up temporary files
RUN rm -rf /tmp/extensions

# Create cache directory for Hugging Face models
RUN mkdir -p /root/.cache/huggingface

# Default command - run the Gradio web demo
EXPOSE 7860
CMD ["python", "app.py"]
