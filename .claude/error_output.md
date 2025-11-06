
 => ERROR [dovsg 17/50] RUN pip install -e . --no-build-isolation                                                                                                       21.2s
------
 > [dovsg 17/50] RUN pip install -e . --no-build-isolation:
20.48 Obtaining file:///app/third_party/GroundingDINO
20.48   Preparing metadata (setup.py): started
20.48   Preparing metadata (setup.py): finished with status 'done'
20.48 Requirement already satisfied: torch in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from groundingdino==0.1.0) (2.3.1+cu121)
20.48 Requirement already satisfied: torchvision in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from groundingdino==0.1.0) (0.18.1+cu121)
20.48 Collecting transformers (from groundingdino==0.1.0)
20.48   Downloading transformers-4.57.1-py3-none-any.whl.metadata (43 kB)
20.48 Collecting addict (from groundingdino==0.1.0)
20.48   Downloading addict-2.4.0-py3-none-any.whl.metadata (1.0 kB)
20.48 Collecting yapf (from groundingdino==0.1.0)
20.48   Downloading yapf-0.43.0-py3-none-any.whl.metadata (46 kB)
20.48 Collecting timm (from groundingdino==0.1.0)
20.48   Downloading timm-1.0.21-py3-none-any.whl.metadata (62 kB)
20.48 Requirement already satisfied: numpy in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from groundingdino==0.1.0) (2.0.2)
20.48 Requirement already satisfied: opencv-python in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from groundingdino==0.1.0) (4.12.0.88)
20.48 Collecting supervision>=0.22.0 (from groundingdino==0.1.0)
20.48   Downloading supervision-0.26.1-py3-none-any.whl.metadata (13 kB)
20.48 Collecting pycocotools (from groundingdino==0.1.0)
20.48   Downloading pycocotools-2.0.10-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata (1.3 kB)
20.48 Collecting scipy>=1.10.0 (from supervision>=0.22.0->groundingdino==0.1.0)
20.48   Downloading scipy-1.13.1-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata (60 kB)
20.48 Requirement already satisfied: matplotlib>=3.6.0 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from supervision>=0.22.0->groundingdino==0.1.0) (3.9.4)
20.48 Requirement already satisfied: pyyaml>=5.3 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from supervision>=0.22.0->groundingdino==0.1.0) (6.0.3)
20.48 Requirement already satisfied: defusedxml>=0.7.1 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from supervision>=0.22.0->groundingdino==0.1.0) (0.7.1)
20.48 Requirement already satisfied: pillow>=9.4 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from supervision>=0.22.0->groundingdino==0.1.0) (11.3.0)
20.48 Requirement already satisfied: requests>=2.26.0 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from supervision>=0.22.0->groundingdino==0.1.0) (2.32.5)
20.48 Requirement already satisfied: tqdm>=4.62.3 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from supervision>=0.22.0->groundingdino==0.1.0) (4.67.1)
20.48 Requirement already satisfied: contourpy>=1.0.1 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from matplotlib>=3.6.0->supervision>=0.22.0->groundingdino==0.1.0) (1.3.0)
20.48 Requirement already satisfied: cycler>=0.10 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from matplotlib>=3.6.0->supervision>=0.22.0->groundingdino==0.1.0) (0.12.1)
20.48 Requirement already satisfied: fonttools>=4.22.0 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from matplotlib>=3.6.0->supervision>=0.22.0->groundingdino==0.1.0) (4.60.1)
20.48 Requirement already satisfied: kiwisolver>=1.3.1 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from matplotlib>=3.6.0->supervision>=0.22.0->groundingdino==0.1.0) (1.4.7)
20.48 Requirement already satisfied: packaging>=20.0 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from matplotlib>=3.6.0->supervision>=0.22.0->groundingdino==0.1.0) (25.0)
20.48 Requirement already satisfied: pyparsing>=2.3.1 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from matplotlib>=3.6.0->supervision>=0.22.0->groundingdino==0.1.0) (3.2.5)
20.48 Requirement already satisfied: python-dateutil>=2.7 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from matplotlib>=3.6.0->supervision>=0.22.0->groundingdino==0.1.0) (2.9.0.post0)
20.48 Requirement already satisfied: importlib-resources>=3.2.0 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from matplotlib>=3.6.0->supervision>=0.22.0->groundingdino==0.1.0) (6.5.2)
20.48 Requirement already satisfied: zipp>=3.1.0 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from importlib-resources>=3.2.0->matplotlib>=3.6.0->supervision>=0.22.0->groundingdino==0.1.0) (3.23.0)
20.48 Requirement already satisfied: six>=1.5 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from python-dateutil>=2.7->matplotlib>=3.6.0->supervision>=0.22.0->groundingdino==0.1.0) (1.17.0)
20.48 Requirement already satisfied: charset_normalizer<4,>=2 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from requests>=2.26.0->supervision>=0.22.0->groundingdino==0.1.0) (3.4.4)
20.48 Requirement already satisfied: idna<4,>=2.5 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from requests>=2.26.0->supervision>=0.22.0->groundingdino==0.1.0) (3.11)
20.48 Requirement already satisfied: urllib3<3,>=1.21.1 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from requests>=2.26.0->supervision>=0.22.0->groundingdino==0.1.0) (2.5.0)
20.48 Requirement already satisfied: certifi>=2017.4.17 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from requests>=2.26.0->supervision>=0.22.0->groundingdino==0.1.0) (2025.10.5)
20.48 Collecting huggingface_hub (from timm->groundingdino==0.1.0)
20.48   Downloading huggingface_hub-1.0.1-py3-none-any.whl.metadata (13 kB)
20.48 Collecting safetensors (from timm->groundingdino==0.1.0)
20.48   Downloading safetensors-0.6.2-cp38-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata (4.1 kB)
20.48 Requirement already satisfied: filelock in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from huggingface_hub->timm->groundingdino==0.1.0) (3.19.1)
20.48 Requirement already satisfied: fsspec>=2023.5.0 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from huggingface_hub->timm->groundingdino==0.1.0) (2025.9.0)
20.48 Requirement already satisfied: httpx<1,>=0.23.0 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from huggingface_hub->timm->groundingdino==0.1.0) (0.28.1)
20.48 Collecting shellingham (from huggingface_hub->timm->groundingdino==0.1.0)
20.48   Downloading shellingham-1.5.4-py2.py3-none-any.whl.metadata (3.5 kB)
20.48 Collecting typer-slim (from huggingface_hub->timm->groundingdino==0.1.0)
20.48   Downloading typer_slim-0.20.0-py3-none-any.whl.metadata (16 kB)
20.48 Requirement already satisfied: typing-extensions>=3.7.4.3 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from huggingface_hub->timm->groundingdino==0.1.0) (4.15.0)
20.48 Collecting hf-xet<2.0.0,>=1.2.0 (from huggingface_hub->timm->groundingdino==0.1.0)
20.48   Downloading hf_xet-1.2.0-cp37-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata (4.9 kB)
20.48 Requirement already satisfied: anyio in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from httpx<1,>=0.23.0->huggingface_hub->timm->groundingdino==0.1.0) (4.11.0)
20.48 Requirement already satisfied: httpcore==1.* in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from httpx<1,>=0.23.0->huggingface_hub->timm->groundingdino==0.1.0) (1.0.9)
20.48 Requirement already satisfied: h11>=0.16 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from httpcore==1.*->httpx<1,>=0.23.0->huggingface_hub->timm->groundingdino==0.1.0) (0.16.0)
20.48 Requirement already satisfied: exceptiongroup>=1.0.2 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from anyio->httpx<1,>=0.23.0->huggingface_hub->timm->groundingdino==0.1.0) (1.3.0)
20.48 Requirement already satisfied: sniffio>=1.1 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from anyio->httpx<1,>=0.23.0->huggingface_hub->timm->groundingdino==0.1.0) (1.3.1)
20.48 Requirement already satisfied: sympy in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from torch->groundingdino==0.1.0) (1.14.0)
20.48 Requirement already satisfied: networkx in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from torch->groundingdino==0.1.0) (3.2.1)
20.48 Requirement already satisfied: jinja2 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from torch->groundingdino==0.1.0) (3.1.6)
20.48 Requirement already satisfied: nvidia-cuda-nvrtc-cu12==12.1.105 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from torch->groundingdino==0.1.0) (12.1.105)
20.48 Requirement already satisfied: nvidia-cuda-runtime-cu12==12.1.105 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from torch->groundingdino==0.1.0) (12.1.105)
20.48 Requirement already satisfied: nvidia-cuda-cupti-cu12==12.1.105 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from torch->groundingdino==0.1.0) (12.1.105)
20.48 Requirement already satisfied: nvidia-cudnn-cu12==8.9.2.26 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from torch->groundingdino==0.1.0) (8.9.2.26)
20.48 Requirement already satisfied: nvidia-cublas-cu12==12.1.3.1 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from torch->groundingdino==0.1.0) (12.1.3.1)
20.48 Requirement already satisfied: nvidia-cufft-cu12==11.0.2.54 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from torch->groundingdino==0.1.0) (11.0.2.54)
20.48 Requirement already satisfied: nvidia-curand-cu12==10.3.2.106 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from torch->groundingdino==0.1.0) (10.3.2.106)
20.48 Requirement already satisfied: nvidia-cusolver-cu12==11.4.5.107 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from torch->groundingdino==0.1.0) (11.4.5.107)
20.48 Requirement already satisfied: nvidia-cusparse-cu12==12.1.0.106 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from torch->groundingdino==0.1.0) (12.1.0.106)
20.48 Requirement already satisfied: nvidia-nccl-cu12==2.20.5 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from torch->groundingdino==0.1.0) (2.20.5)
20.48 Requirement already satisfied: nvidia-nvtx-cu12==12.1.105 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from torch->groundingdino==0.1.0) (12.1.105)
20.48 Requirement already satisfied: triton==2.3.1 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from torch->groundingdino==0.1.0) (2.3.1)
20.48 Requirement already satisfied: nvidia-nvjitlink-cu12 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from nvidia-cusolver-cu12==11.4.5.107->torch->groundingdino==0.1.0) (12.9.86)
20.48 Requirement already satisfied: MarkupSafe>=2.0 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from jinja2->torch->groundingdino==0.1.0) (2.1.5)
20.48 Requirement already satisfied: mpmath<1.4,>=1.1.0 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from sympy->torch->groundingdino==0.1.0) (1.3.0)
20.48 Collecting huggingface_hub (from timm->groundingdino==0.1.0)
20.48   Downloading huggingface_hub-0.36.0-py3-none-any.whl.metadata (14 kB)
20.48 Collecting regex!=2019.12.17 (from transformers->groundingdino==0.1.0)
20.48   Downloading regex-2025.10.23-cp39-cp39-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl.metadata (40 kB)
20.48 Collecting tokenizers<=0.23.0,>=0.22.0 (from transformers->groundingdino==0.1.0)
20.48   Downloading tokenizers-0.22.1-cp39-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata (6.8 kB)
20.48 Collecting click>=8.0.0 (from typer-slim->huggingface_hub->timm->groundingdino==0.1.0)
20.48   Downloading click-8.1.8-py3-none-any.whl.metadata (2.3 kB)
20.48 Requirement already satisfied: platformdirs>=3.5.1 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from yapf->groundingdino==0.1.0) (4.4.0)
20.48 Requirement already satisfied: tomli>=2.0.1 in /opt/conda/envs/dovsg/lib/python3.9/site-packages (from yapf->groundingdino==0.1.0) (2.3.0)
20.48 Downloading supervision-0.26.1-py3-none-any.whl (207 kB)
20.48 Downloading scipy-1.13.1-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (38.6 MB)
20.48    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 38.6/38.6 MB 37.8 MB/s  0:00:01
20.48 Downloading addict-2.4.0-py3-none-any.whl (3.8 kB)
20.48 Downloading pycocotools-2.0.10-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (453 kB)
20.48 Downloading timm-1.0.21-py3-none-any.whl (2.5 MB)
20.48    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 2.5/2.5 MB 43.9 MB/s  0:00:00
20.48 Downloading hf_xet-1.2.0-cp37-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (3.3 MB)
20.48    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 3.3/3.3 MB 42.7 MB/s  0:00:00
20.48 Downloading safetensors-0.6.2-cp38-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (485 kB)
20.48 Downloading transformers-4.57.1-py3-none-any.whl (12.0 MB)
20.48    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 12.0/12.0 MB 43.8 MB/s  0:00:00
20.48 Downloading huggingface_hub-0.36.0-py3-none-any.whl (566 kB)
20.48    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 566.1/566.1 kB 33.7 MB/s  0:00:00
20.48 Downloading tokenizers-0.22.1-cp39-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (3.3 MB)
20.48    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 3.3/3.3 MB 42.3 MB/s  0:00:00
20.48 Downloading regex-2025.10.23-cp39-cp39-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl (791 kB)
20.48    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 791.1/791.1 kB 26.0 MB/s  0:00:00
20.48 Downloading yapf-0.43.0-py3-none-any.whl (256 kB)
20.48 Installing collected packages: addict, yapf, scipy, safetensors, regex, pycocotools, hf-xet, huggingface_hub, tokenizers, supervision, transformers, timm, groundingdino
20.48   Running setup.py develop for groundingdino
20.48 
20.48   DEPRECATION: Legacy editable install of groundingdino==0.1.0 from file:///app/third_party/GroundingDINO (setup.py develop) is deprecated. pip 25.3 will enforce this behaviour change. A possible replacement is to add a pyproject.toml or enable --use-pep517, and use setuptools >= 64. If the resulting installation is not behaving as expected, try using --config-settings editable_mode=compat. Please consult the setuptools documentation for more information. Discussion can be found at https://github.com/pypa/pip/issues/11457
20.48     error: subprocess-exited-with-error
20.48     
20.48     × python setup.py develop did not run successfully.
20.48     │ exit code: 1
20.48     ╰─> [92 lines of output]
20.48         No CUDA runtime is found, using CUDA_HOME='/usr/local/cuda-12.1'
20.48         Building wheel groundingdino-0.1.0
20.48         Compiling with CUDA
20.48         running develop
20.48         /opt/conda/envs/dovsg/lib/python3.9/site-packages/setuptools/_distutils/cmd.py:90: DevelopDeprecationWarning: develop command is deprecated.
20.48         !!
20.48         
20.48                 ********************************************************************************
20.48                 Please avoid running ``setup.py`` and ``develop``.
20.48                 Instead, use standards-based tools like pip or uv.
20.48         
20.48                 By 2025-Oct-31, you need to update your project and remove deprecated calls
20.48                 or your builds will no longer be supported.
20.48         
20.48                 See https://github.com/pypa/setuptools/issues/917 for details.
20.48                 ********************************************************************************
20.48         
20.48         !!
20.48           self.initialize_options()
20.48         Obtaining file:///app/third_party/GroundingDINO
20.48           Installing build dependencies: started
20.48           Installing build dependencies: finished with status 'done'
20.48           Checking if build backend supports build_editable: started
20.48           Checking if build backend supports build_editable: finished with status 'done'
20.48           Getting requirements to build editable: started
20.48           Getting requirements to build editable: finished with status 'error'
20.48           error: subprocess-exited-with-error
20.48         
20.48           × Getting requirements to build editable did not run successfully.
20.48           │ exit code: 1
20.48           ╰─> [29 lines of output]
20.48               /opt/conda/envs/dovsg/bin/python3.9: No module named pip
20.48               Traceback (most recent call last):
20.48                 File "<string>", line 32, in install_torch
20.48               ModuleNotFoundError: No module named 'torch'
20.48         
20.48               During handling of the above exception, another exception occurred:
20.48         
20.48               Traceback (most recent call last):
20.48                 File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/pip/_vendor/pyproject_hooks/_in_process/_in_process.py", line 389, in <module>
20.48                   main()
20.48                 File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/pip/_vendor/pyproject_hooks/_in_process/_in_process.py", line 373, in main
20.48                   json_out["return_val"] = hook(**hook_input["kwargs"])
20.48                 File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/pip/_vendor/pyproject_hooks/_in_process/_in_process.py", line 157, in get_requires_for_build_editable
20.48                   return hook(config_settings)
20.48                 File "/tmp/pip-build-env-s3uwoh4g/overlay/lib/python3.9/site-packages/setuptools/build_meta.py", line 473, in get_requires_for_build_editable
20.48                   return self.get_requires_for_build_wheel(config_settings)
20.48                 File "/tmp/pip-build-env-s3uwoh4g/overlay/lib/python3.9/site-packages/setuptools/build_meta.py", line 331, in get_requires_for_build_wheel
20.48                   return self._get_build_requires(config_settings, requirements=[])
20.48                 File "/tmp/pip-build-env-s3uwoh4g/overlay/lib/python3.9/site-packages/setuptools/build_meta.py", line 301, in _get_build_requires
20.48                   self.run_setup()
20.48                 File "/tmp/pip-build-env-s3uwoh4g/overlay/lib/python3.9/site-packages/setuptools/build_meta.py", line 512, in run_setup
20.48                   super().run_setup(setup_script=setup_script)
20.48                 File "/tmp/pip-build-env-s3uwoh4g/overlay/lib/python3.9/site-packages/setuptools/build_meta.py", line 317, in run_setup
20.48                   exec(code, locals())
20.48                 File "<string>", line 37, in <module>
20.48                 File "<string>", line 34, in install_torch
20.48                 File "/opt/conda/envs/dovsg/lib/python3.9/subprocess.py", line 373, in check_call
20.48                   raise CalledProcessError(retcode, cmd)
20.48               subprocess.CalledProcessError: Command '['/opt/conda/envs/dovsg/bin/python3.9', '-m', 'pip', 'install', 'torch']' returned non-zero exit status 1.
20.48               [end of output]
20.48         
20.48           note: This error originates from a subprocess, and is likely not a problem with pip.
20.48         error: subprocess-exited-with-error
20.48         
20.48         × Getting requirements to build editable did not run successfully.
20.48         │ exit code: 1
20.48         ╰─> See above for output.
20.48         
20.48         note: This error originates from a subprocess, and is likely not a problem with pip.
20.48         Traceback (most recent call last):
20.48           File "<string>", line 2, in <module>
20.48           File "<pip-setuptools-caller>", line 35, in <module>
20.48           File "/app/third_party/GroundingDINO/setup.py", line 204, in <module>
20.48             setup(
20.48           File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/setuptools/__init__.py", line 115, in setup
20.48             return distutils.core.setup(**attrs)
20.48           File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/setuptools/_distutils/core.py", line 186, in setup
20.48             return run_commands(dist)
20.48           File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/setuptools/_distutils/core.py", line 202, in run_commands
20.48             dist.run_commands()
20.48           File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/setuptools/_distutils/dist.py", line 1002, in run_commands
20.48             self.run_command(cmd)
20.48           File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/setuptools/dist.py", line 1102, in run_command
20.48             super().run_command(command)
20.48           File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/setuptools/_distutils/dist.py", line 1021, in run_command
20.48             cmd_obj.run()
20.48           File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/setuptools/command/develop.py", line 39, in run
20.48             subprocess.check_call(cmd)
20.48           File "/opt/conda/envs/dovsg/lib/python3.9/subprocess.py", line 373, in check_call
20.48             raise CalledProcessError(retcode, cmd)
20.48         subprocess.CalledProcessError: Command '['/opt/conda/envs/dovsg/bin/python3.9', '-m', 'pip', 'install', '-e', '.', '--use-pep517', '--no-deps']' returned non-zero exit status 1.
20.48         [end of output]
20.48     
20.48     note: This error originates from a subprocess, and is likely not a problem with pip.
20.48 error: subprocess-exited-with-error
20.48 
20.48 × python setup.py develop did not run successfully.
20.48 │ exit code: 1
20.48 ╰─> [92 lines of output]
20.48     No CUDA runtime is found, using CUDA_HOME='/usr/local/cuda-12.1'
20.48     Building wheel groundingdino-0.1.0
20.48     Compiling with CUDA
20.48     running develop
20.48     /opt/conda/envs/dovsg/lib/python3.9/site-packages/setuptools/_distutils/cmd.py:90: DevelopDeprecationWarning: develop command is deprecated.
20.48     !!
20.48     
20.48             ********************************************************************************
20.48             Please avoid running ``setup.py`` and ``develop``.
20.48             Instead, use standards-based tools like pip or uv.
20.48     
20.48             By 2025-Oct-31, you need to update your project and remove deprecated calls
20.48             or your builds will no longer be supported.
20.48     
20.48             See https://github.com/pypa/setuptools/issues/917 for details.
20.48             ********************************************************************************
20.48     
20.48     !!
20.48       self.initialize_options()
20.48     Obtaining file:///app/third_party/GroundingDINO
20.48       Installing build dependencies: started
20.48       Installing build dependencies: finished with status 'done'
20.48       Checking if build backend supports build_editable: started
20.48       Checking if build backend supports build_editable: finished with status 'done'
20.48       Getting requirements to build editable: started
20.48       Getting requirements to build editable: finished with status 'error'
20.48       error: subprocess-exited-with-error
20.48     
20.48       × Getting requirements to build editable did not run successfully.
20.48       │ exit code: 1
20.48       ╰─> [29 lines of output]
20.48           /opt/conda/envs/dovsg/bin/python3.9: No module named pip
20.48           Traceback (most recent call last):
20.48             File "<string>", line 32, in install_torch
20.48           ModuleNotFoundError: No module named 'torch'
20.48     
20.48           During handling of the above exception, another exception occurred:
20.48     
20.48           Traceback (most recent call last):
20.48             File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/pip/_vendor/pyproject_hooks/_in_process/_in_process.py", line 389, in <module>
20.48               main()
20.48             File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/pip/_vendor/pyproject_hooks/_in_process/_in_process.py", line 373, in main
20.48               json_out["return_val"] = hook(**hook_input["kwargs"])
20.48             File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/pip/_vendor/pyproject_hooks/_in_process/_in_process.py", line 157, in get_requires_for_build_editable
20.48               return hook(config_settings)
20.48             File "/tmp/pip-build-env-s3uwoh4g/overlay/lib/python3.9/site-packages/setuptools/build_meta.py", line 473, in get_requires_for_build_editable
20.48               return self.get_requires_for_build_wheel(config_settings)
20.48             File "/tmp/pip-build-env-s3uwoh4g/overlay/lib/python3.9/site-packages/setuptools/build_meta.py", line 331, in get_requires_for_build_wheel
20.48               return self._get_build_requires(config_settings, requirements=[])
20.48             File "/tmp/pip-build-env-s3uwoh4g/overlay/lib/python3.9/site-packages/setuptools/build_meta.py", line 301, in _get_build_requires
20.48               self.run_setup()
20.48             File "/tmp/pip-build-env-s3uwoh4g/overlay/lib/python3.9/site-packages/setuptools/build_meta.py", line 512, in run_setup
20.48               super().run_setup(setup_script=setup_script)
20.48             File "/tmp/pip-build-env-s3uwoh4g/overlay/lib/python3.9/site-packages/setuptools/build_meta.py", line 317, in run_setup
20.48               exec(code, locals())
20.48             File "<string>", line 37, in <module>
20.48             File "<string>", line 34, in install_torch
20.48             File "/opt/conda/envs/dovsg/lib/python3.9/subprocess.py", line 373, in check_call
20.48               raise CalledProcessError(retcode, cmd)
20.48           subprocess.CalledProcessError: Command '['/opt/conda/envs/dovsg/bin/python3.9', '-m', 'pip', 'install', 'torch']' returned non-zero exit status 1.
20.48           [end of output]
20.48     
20.48       note: This error originates from a subprocess, and is likely not a problem with pip.
20.48     error: subprocess-exited-with-error
20.48     
20.48     × Getting requirements to build editable did not run successfully.
20.48     │ exit code: 1
20.48     ╰─> See above for output.
20.48     
20.48     note: This error originates from a subprocess, and is likely not a problem with pip.
20.48     Traceback (most recent call last):
20.48       File "<string>", line 2, in <module>
20.48       File "<pip-setuptools-caller>", line 35, in <module>
20.48       File "/app/third_party/GroundingDINO/setup.py", line 204, in <module>
20.48         setup(
20.48       File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/setuptools/__init__.py", line 115, in setup
20.48         return distutils.core.setup(**attrs)
20.48       File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/setuptools/_distutils/core.py", line 186, in setup
20.48         return run_commands(dist)
20.48       File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/setuptools/_distutils/core.py", line 202, in run_commands
20.48         dist.run_commands()
20.48       File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/setuptools/_distutils/dist.py", line 1002, in run_commands
20.48         self.run_command(cmd)
20.48       File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/setuptools/dist.py", line 1102, in run_command
20.48         super().run_command(command)
20.48       File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/setuptools/_distutils/dist.py", line 1021, in run_command
20.48         cmd_obj.run()
20.48       File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/setuptools/command/develop.py", line 39, in run
20.48         subprocess.check_call(cmd)
20.48       File "/opt/conda/envs/dovsg/lib/python3.9/subprocess.py", line 373, in check_call
20.48         raise CalledProcessError(retcode, cmd)
20.48     subprocess.CalledProcessError: Command '['/opt/conda/envs/dovsg/bin/python3.9', '-m', 'pip', 'install', '-e', '.', '--use-pep517', '--no-deps']' returned non-zero exit status 1.
20.48     [end of output]
20.48 
20.48 note: This error originates from a subprocess, and is likely not a problem with pip.
20.48 
20.48 ERROR conda.cli.main_run:execute(127): `conda run /bin/bash -c pip install -e . --no-build-isolation` failed. (See above for error)
20.48 
------
failed to solve: process "conda run -n dovsg /bin/bash -c pip install -e . --no-build-isolation" did not complete successfully: exit code: 1