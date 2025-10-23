cerlab@cerlab72:~/4DSG/docker$ docker compose exec dovsg python -u demo.py   --tags room1   --preprocess   --debug   --skip_task_planning   --skip_ace   --skip_lightglue \
> 


Pose Estimation in progress, please waiting for a moment...


point cloud: 100%|████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 247/247 [00:13<00:00, 18.66it/s]

FutureWarning: Importing from timm.models.layers is deprecated, please import via timm.layers
UserWarning: torch.meshgrid: in an upcoming release, it will be required to pass the indexing argument. (Triggered internally at ../aten/src/ATen/native/TensorShape.cpp:3587.)
final text_encoder_type: bert-base-uncased
Some weights of the model checkpoint at bert-base-uncased were not used when initializing BertModel: ['cls.seq_relationship.weight', 'cls.predictions.transform.dense.bias', 'cls.seq_relationship.bias', 'cls.predictions.bias', 'cls.predictions.transform.LayerNorm.weight', 'cls.predictions.transform.LayerNorm.bias', 'cls.predictions.transform.dense.weight']
- This IS expected if you are initializing BertModel from the checkpoint of a model trained on another task or with another architecture (e.g. initializing a BertForSequenceClassification model from a BertForPreTraining model).
- This IS NOT expected if you are initializing BertModel from the checkpoint of a model that you expect to be exactly identical (initializing a BertForSequenceClassification model from a BertForSequenceClassification model).
get floor pcd and transform scene.:   0%|                                                                                                                           | 0/247 [00:00<?, ?it/s]UserWarning: torch.utils.checkpoint: the use_reentrant parameter should be passed explicitly. In version 2.4 we will raise an exception if use_reentrant is not passed. use_reentrant=False is recommended, but if you need to preserve the current default behavior, you can pass use_reentrant=True. Refer to docs for more details on the differences between the two variants.
UserWarning: None of the inputs have requires_grad=True. Gradients will be None
get floor pcd and transform scene.:  11%|████████████▉                                                                                                     | 28/247 [00:04<00:35,  6.15it/s]UserWarning: The given NumPy array is not writable, and PyTorch does not support non-writable tensors. This means writing to this tensor will result in undefined behavior. You may want to copy the array to protect its data or make it writable before converting it to a tensor. This type of warning will be suppressed for the rest of this program. (Triggered internally at ../torch/csrc/utils/tensor_numpy.cpp:206.)
UserWarning: Memory efficient kernel not used because: (Triggered internally at ../aten/src/ATen/native/transformers/cuda/sdp_utils.cpp:607.)
UserWarning: Memory Efficient attention has been runtime disabled. (Triggered internally at ../aten/src/ATen/native/transformers/sdp_utils_cpp.h:495.)
UserWarning: Flash attention kernel not used because: (Triggered internally at ../aten/src/ATen/native/transformers/cuda/sdp_utils.cpp:609.)
UserWarning: Expected query, key and value to all be of dtype: {Half, BFloat16}. Got Query dtype: float, Key dtype: float, and Value dtype: float instead. (Triggered internally at ../aten/src/ATen/native/transformers/sdp_utils_cpp.h:98.)
UserWarning: CuDNN attention kernel not used because: (Triggered internally at ../aten/src/ATen/native/transformers/cuda/sdp_utils.cpp:611.)
UserWarning: The CuDNN backend needs to be enabled by setting the enviornment variable`TORCH_CUDNN_SDPA_ENABLED=1` (Triggered internally at ../aten/src/ATen/native/transformers/cuda/sdp_utils.cpp:409.)
UserWarning: Flash Attention kernel failed due to: No available kernel. Aborting execution.
Falling back to all available kernels for scaled_dot_product_attention (which may have a slower speed).
get floor pcd and transform scene.: 100%|█████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 247/247 [01:15<00:00,  3.28it/s]
point cloud: 100%|████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 247/247 [00:13<00:00, 18.80it/s]
Loading data: 100%|███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 247/247 [02:11<00:00,  1.87it/s]
voxel map: 100%|██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 247/247 [00:34<00:00,  7.21it/s]
===> get unique global points and colors
final text_encoder_type: bert-base-uncased
Some weights of the model checkpoint at bert-base-uncased were not used when initializing BertModel: ['cls.seq_relationship.weight', 'cls.predictions.transform.dense.bias', 'cls.seq_relationship.bias', 'cls.predictions.bias', 'cls.predictions.transform.LayerNorm.weight', 'cls.predictions.transform.LayerNorm.bias', 'cls.predictions.transform.dense.weight']
- This IS expected if you are initializing BertModel from the checkpoint of a model trained on another task or with another architecture (e.g. initializing a BertForSequenceClassification model from a BertForPreTraining model).
- This IS NOT expected if you are initializing BertModel from the checkpoint of a model that you expect to be exactly identical (initializing a BertForSequenceClassification model from a BertForSequenceClassification model).
==> Initializing CLIP model...
==> Done initializing CLIP model.
/encoder/layer/0/crossattention/self/query is tied
/encoder/layer/0/crossattention/self/key is tied
/encoder/layer/0/crossattention/self/value is tied
/encoder/layer/0/crossattention/output/dense is tied
/encoder/layer/0/crossattention/output/LayerNorm is tied
/encoder/layer/0/intermediate/dense is tied
/encoder/layer/0/output/dense is tied
/encoder/layer/0/output/LayerNorm is tied
/encoder/layer/1/crossattention/self/query is tied
/encoder/layer/1/crossattention/self/key is tied
/encoder/layer/1/crossattention/self/value is tied
/encoder/layer/1/crossattention/output/dense is tied
/encoder/layer/1/crossattention/output/LayerNorm is tied
/encoder/layer/1/intermediate/dense is tied
/encoder/layer/1/output/dense is tied
/encoder/layer/1/output/LayerNorm is tied
--------------
checkpoints/recognize_anything/ram_swin_large_14m.pth
--------------
load checkpoint from checkpoints/recognize_anything/ram_swin_large_14m.pth
vit: swin_l
Traceback (most recent call last):
  File "/app/demo.py", line 96, in <module>
    main(args)
  File "/app/demo.py", line 41, in main
    controller.get_semantic_memory()
  File "/app/dovsg/controller.py", line 865, in get_semantic_memory
    semantic_memory = RamGroundingDinoSAM2ClipDataset(
  File "/app/dovsg/memory/ram_groundingdino_sam2_clip_semantic_memory.py", line 48, in __init__
    self.tagging_model = tagging_model.eval().to(self.device)
  File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/torch/nn/modules/module.py", line 1173, in to
    return self._apply(convert)
  File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/torch/nn/modules/module.py", line 779, in _apply
    module._apply(fn)
  File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/torch/nn/modules/module.py", line 779, in _apply
    module._apply(fn)
  File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/torch/nn/modules/module.py", line 779, in _apply
    module._apply(fn)
  [Previous line repeated 5 more times]
  File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/torch/nn/modules/module.py", line 804, in _apply
    param_applied = fn(param)
  File "/opt/conda/envs/dovsg/lib/python3.9/site-packages/torch/nn/modules/module.py", line 1159, in convert
    return t.to(
torch.cuda.OutOfMemoryError: CUDA out of memory. Tried to allocate 20.00 MiB. GPU