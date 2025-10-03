cerlab@cerlab72:~/4DSG/docker$ docker exec dovsg-main bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/demo.py --tags room1 --preprocess"

Pose Estimation in progress, please waiting for a moment...

Found exist data_example/room1/memory/3_0.1_0.01_True_0.2_0.5/step_0/pointcloud_droidslam_False.ply, loading it!


get floor pcd and transform scene.: 100%|██████████| 247/247 [00:13<00:00, 18.03it/s]
Train ACE
INFO:ace.ace_trainer:Loaded training scan from: data_example/room1 -- 739 images, mean: 2.20 -0.19 1.15
INFO:ace.ace_network:Creating Regressor using pretrained encoder with 512 feature size.
INFO:ace.ace_trainer:Loaded pretrained encoder from: ace/ace_encoder_pretrained.pt
INFO:ace.ace_trainer:Starting creation of the training buffer.
filling training buffers with 1000000/3000000 samples
filling training buffers with 2000000/3000000 samples
filling training buffers with 3000000/3000000 samples
INFO:ace.ace_trainer:Created buffer of 3.22GB with 8 passes over the training data.
INFO:ace.ace_trainer:Filled training buffer in 21.6s.
INFO:ace.ace_trainer:Iteration:      0 / Epoch 000|016, Loss: 23.6, Valid: 17.7%, Time: 24.52s
...
INFO:ace.ace_trainer:Iteration:  18700 / Epoch 015|016, Loss: 3.6, Valid: 98.9%, Time: 97.86s
INFO:ace.ace_trainer:Saved trained head weights to: data_example/room1/ace/ace.pt
INFO:ace.ace_trainer:Done without errors. Creating buffer time: 21.6 seconds. Training time: 76.4 seconds. Total time: 98.0 seconds.
Train ACE Over!
point cloud: 100%|██████████| 247/247 [00:12<00:00, 19.69it/s]

Found cache view_dataset, loading it!

Found cache semantic_memory, don't need process!


Exsit instances objects in data_example/room1/memory/3_0.1_0.01_True_0.2_0.5/step_0/instance_objects.pkl
INFO:root:Parsing model identifier. Schema: None, Identifier: ViT-H-14
INFO:root:Loaded built-in ViT-H-14 model config.
INFO:root:Instantiating model architecture: CLIP
INFO:root:Loading full pretrained weights from: /root/.cache/huggingface/hub/models--laion--CLIP-ViT-H-14-laion2B-s32B-b79K/snapshots/1c2b8495b28150b8a4922ee1c8edee224c284c0c/open_clip_model.safetensors
INFO:root:Final image preprocessing configuration set: {'size': (224, 224), 'mode': 'RGB', 'mean': (0.48145466, 0.4578275, 0.40821073), 'std': (0.26862954, 0.26130258, 0.27577711), 'interpolation': 'bicubic', 'resize_mode': 'shortest', 'fill_color': 0}
INFO:root:Model ViT-H-14 creation process complete.
INFO:root:Parsing tokenizer identifier. Schema: None, Identifier: ViT-H-14
INFO:root:Attempting to load config from built-in: ViT-H-14
INFO:root:Using default SimpleTokenizer.
get background indexes.
Enter your query: Traceback (most recent call last):
  File "/app/demo.py", line 91, in <module>
    main(args)
  File "/app/demo.py", line 56, in main
    controller.show_instances(
  File "/app/dovsg/controller.py", line 1188, in show_instances
    pcds = vis_instances(
  File "/app/dovsg/memory/instances/visualize_instances.py", line 366, in vis_instances
    vis.run()
  File "/app/dovsg/memory/instances/visualize_instances.py", line 309, in color_by_clip_sim
    text_query = input("Enter your query: ")
EOFError: EOF when reading a line