cerlab@cerlab72:~/4DSG/docker$ docker exec -it dovsg-main conda run -n dovsg python demo.py --tags room1 --preprocess --debug
DEBUG conda.gateways.logging:set_log_level(223): log_level set to 10
DEBUG conda.gateways.subprocess:subprocess_call(97): executing>> /usr/bin/bash /tmp/tmp5u35jhyf


Pose Estimation in progress, please waiting for a moment...




Found exist data_example/room1/memory/3_0.1_0.01_True_0.2_0.5/step_0/pointcloud_droidslam_False.ply, loading it!


Train ACE
filling training buffers with 1000000/3000000 samples
filling training buffers with 2000000/3000000 samples
filling training buffers with 3000000/3000000 samples
Train ACE Over!


Found cache view_dataset, loading it!




get floor pcd and transform scene.:   0%|          | 0/247 [00:00<?, ?it/s]
get floor pcd and transform scene.:   2%|▏         | 4/247 [00:00<00:06, 37.75it/s]
get floor pcd and transform scene.:   4%|▎         | 9/247 [00:00<00:05, 41.33it/s]
get floor pcd and transform scene.:   6%|▌         | 14/247 [00:00<00:05, 42.28it/s]
get floor pcd and transform scene.:   8%|▊         | 19/247 [00:00<00:05, 43.08it/s]
get floor pcd and transform scene.:  10%|▉         | 24/247 [00:00<00:05, 42.87it/s]
get floor pcd and transform scene.:  12%|█▏        | 29/247 [00:00<00:05, 42.91it/s]
get floor pcd and transform scene.:  14%|█▍        | 34/247 [00:00<00:04, 42.97it/s]
get floor pcd and transform scene.:  16%|█▌        | 39/247 [00:00<00:04, 43.08it/s]
get floor pcd and transform scene.:  18%|█▊        | 44/247 [00:01<00:04, 43.03it/s]
get floor pcd and transform scene.:  20%|█▉        | 49/247 [00:01<00:04, 42.87it/s]
get floor pcd and transform scene.:  22%|██▏       | 54/247 [00:01<00:04, 43.26it/s]
get floor pcd and transform scene.:  24%|██▍       | 59/247 [00:01<00:04, 43.26it/s]
get floor pcd and transform scene.:  26%|██▌       | 64/247 [00:01<00:04, 43.37it/s]
get floor pcd and transform scene.:  28%|██▊       | 69/247 [00:01<00:04, 43.36it/s]
get floor pcd and transform scene.:  30%|██▉       | 74/247 [00:01<00:04, 42.59it/s]
get floor pcd and transform scene.:  32%|███▏      | 79/247 [00:01<00:04, 40.57it/s]
get floor pcd and transform scene.:  34%|███▍      | 84/247 [00:01<00:03, 41.06it/s]
get floor pcd and transform scene.:  36%|███▌      | 89/247 [00:02<00:03, 40.94it/s]
get floor pcd and transform scene.:  38%|███▊      | 94/247 [00:02<00:03, 41.16it/s]
get floor pcd and transform scene.:  40%|████      | 99/247 [00:02<00:03, 41.58it/s]
get floor pcd and transform scene.:  42%|████▏     | 104/247 [00:02<00:03, 42.39it/s]
get floor pcd and transform scene.:  44%|████▍     | 109/247 [00:02<00:03, 42.77it/s]
get floor pcd and transform scene.:  46%|████▌     | 114/247 [00:02<00:03, 42.59it/s]
get floor pcd and transform scene.:  48%|████▊     | 119/247 [00:02<00:02, 42.83it/s]
get floor pcd and transform scene.:  50%|█████     | 124/247 [00:02<00:02, 41.83it/s]
get floor pcd and transform scene.:  52%|█████▏    | 129/247 [00:03<00:02, 41.82it/s]
get floor pcd and transform scene.:  54%|█████▍    | 134/247 [00:03<00:02, 41.87it/s]
get floor pcd and transform scene.:  56%|█████▋    | 139/247 [00:03<00:02, 41.93it/s]
get floor pcd and transform scene.:  58%|█████▊    | 144/247 [00:03<00:02, 41.73it/s]
get floor pcd and transform scene.:  60%|██████    | 149/247 [00:03<00:02, 41.83it/s]
get floor pcd and transform scene.:  62%|██████▏   | 154/247 [00:03<00:02, 40.91it/s]
get floor pcd and transform scene.:  64%|██████▍   | 159/247 [00:03<00:02, 41.16it/s]
get floor pcd and transform scene.:  66%|██████▋   | 164/247 [00:03<00:02, 41.43it/s]
get floor pcd and transform scene.:  68%|██████▊   | 169/247 [00:04<00:01, 41.68it/s]
get floor pcd and transform scene.:  70%|███████   | 174/247 [00:04<00:01, 41.84it/s]
get floor pcd and transform scene.:  72%|███████▏  | 179/247 [00:04<00:01, 42.03it/s]
get floor pcd and transform scene.:  74%|███████▍  | 184/247 [00:04<00:01, 41.90it/s]
get floor pcd and transform scene.:  77%|███████▋  | 189/247 [00:04<00:01, 42.16it/s]
get floor pcd and transform scene.:  79%|███████▊  | 194/247 [00:04<00:01, 42.25it/s]
get floor pcd and transform scene.:  81%|████████  | 199/247 [00:04<00:01, 42.25it/s]
get floor pcd and transform scene.:  83%|████████▎ | 204/247 [00:04<00:01, 42.21it/s]
get floor pcd and transform scene.:  85%|████████▍ | 209/247 [00:04<00:00, 42.26it/s]
get floor pcd and transform scene.:  87%|████████▋ | 214/247 [00:05<00:00, 42.30it/s]
get floor pcd and transform scene.:  89%|████████▊ | 219/247 [00:05<00:00, 42.40it/s]
get floor pcd and transform scene.:  91%|█████████ | 224/247 [00:05<00:00, 42.66it/s]
get floor pcd and transform scene.:  93%|█████████▎| 229/247 [00:05<00:00, 42.36it/s]
get floor pcd and transform scene.:  95%|█████████▍| 234/247 [00:05<00:00, 41.22it/s]
get floor pcd and transform scene.:  97%|█████████▋| 239/247 [00:05<00:00, 41.47it/s]
get floor pcd and transform scene.:  99%|█████████▉| 244/247 [00:05<00:00, 41.93it/s]
get floor pcd and transform scene.: 100%|██████████| 247/247 [00:05<00:00, 42.13it/s]
INFO:ace.ace_trainer:Loaded training scan from: data_example/room1 -- 739 images, mean: 2.20 -0.19 1.15
INFO:ace.ace_network:Creating Regressor using pretrained encoder with 512 feature size.
INFO:ace.ace_trainer:Loaded pretrained encoder from: ace/ace_encoder_pretrained.pt
INFO:ace.ace_trainer:Starting creation of the training buffer.
INFO:ace.ace_trainer:Created buffer of 3.22GB with 8 passes over the training data.
INFO:ace.ace_trainer:Filled training buffer in 21.6s.
INFO:ace.ace_trainer:Iteration:      0 / Epoch 000|016, Loss: 23.6, Valid: 17.7%, Time: 21.94s
INFO:ace.ace_trainer:Iteration:    100 / Epoch 000|016, Loss: 37.8, Valid: 63.9%, Time: 22.31s
INFO:ace.ace_trainer:Iteration:    200 / Epoch 000|016, Loss: 37.8, Valid: 67.1%, Time: 22.67s
INFO:ace.ace_trainer:Iteration:    300 / Epoch 000|016, Loss: 37.9, Valid: 67.5%, Time: 23.04s
INFO:ace.ace_trainer:Iteration:    400 / Epoch 000|016, Loss: 36.8, Valid: 67.9%, Time: 23.41s
INFO:ace.ace_trainer:Iteration:    500 / Epoch 000|016, Loss: 37.3, Valid: 71.4%, Time: 23.78s
INFO:ace.ace_trainer:Iteration:    600 / Epoch 000|016, Loss: 36.6, Valid: 70.0%, Time: 24.18s
INFO:ace.ace_trainer:Iteration:    700 / Epoch 000|016, Loss: 36.9, Valid: 74.4%, Time: 24.57s
INFO:ace.ace_trainer:Iteration:    800 / Epoch 000|016, Loss: 36.9, Valid: 74.6%, Time: 24.94s
INFO:ace.ace_trainer:Iteration:    900 / Epoch 000|016, Loss: 36.7, Valid: 76.6%, Time: 25.32s
INFO:ace.ace_trainer:Iteration:   1000 / Epoch 000|016, Loss: 35.6, Valid: 76.2%, Time: 25.72s
INFO:ace.ace_trainer:Iteration:   1100 / Epoch 000|016, Loss: 34.1, Valid: 74.3%, Time: 26.12s
INFO:ace.ace_trainer:Iteration:   1200 / Epoch 001|016, Loss: 34.2, Valid: 77.5%, Time: 26.55s
INFO:ace.ace_trainer:Iteration:   1300 / Epoch 001|016, Loss: 33.2, Valid: 75.3%, Time: 26.93s
INFO:ace.ace_trainer:Iteration:   1400 / Epoch 001|016, Loss: 31.6, Valid: 76.1%, Time: 27.30s
INFO:ace.ace_trainer:Iteration:   1500 / Epoch 001|016, Loss: 30.9, Valid: 77.0%, Time: 27.70s
INFO:ace.ace_trainer:Iteration:   1600 / Epoch 001|016, Loss: 30.2, Valid: 80.0%, Time: 28.09s
INFO:ace.ace_trainer:Iteration:   1700 / Epoch 001|016, Loss: 29.7, Valid: 80.8%, Time: 28.47s
INFO:ace.ace_trainer:Iteration:   1800 / Epoch 001|016, Loss: 28.9, Valid: 79.6%, Time: 28.85s
INFO:ace.ace_trainer:Iteration:   1900 / Epoch 001|016, Loss: 28.8, Valid: 82.2%, Time: 29.25s
INFO:ace.ace_trainer:Iteration:   2000 / Epoch 001|016, Loss: 28.3, Valid: 83.6%, Time: 29.65s
INFO:ace.ace_trainer:Iteration:   2100 / Epoch 001|016, Loss: 27.3, Valid: 82.6%, Time: 30.05s
INFO:ace.ace_trainer:Iteration:   2200 / Epoch 001|016, Loss: 27.4, Valid: 83.9%, Time: 30.42s
INFO:ace.ace_trainer:Iteration:   2300 / Epoch 001|016, Loss: 26.2, Valid: 84.2%, Time: 30.78s
INFO:ace.ace_trainer:Iteration:   2400 / Epoch 002|016, Loss: 25.7, Valid: 84.1%, Time: 31.20s
INFO:ace.ace_trainer:Iteration:   2500 / Epoch 002|016, Loss: 25.9, Valid: 86.6%, Time: 31.56s
INFO:ace.ace_trainer:Iteration:   2600 / Epoch 002|016, Loss: 25.7, Valid: 87.8%, Time: 31.93s
INFO:ace.ace_trainer:Iteration:   2700 / Epoch 002|016, Loss: 25.1, Valid: 88.0%, Time: 32.31s
INFO:ace.ace_trainer:Iteration:   2800 / Epoch 002|016, Loss: 25.7, Valid: 89.1%, Time: 32.68s
INFO:ace.ace_trainer:Iteration:   2900 / Epoch 002|016, Loss: 24.2, Valid: 90.5%, Time: 33.06s
INFO:ace.ace_trainer:Iteration:   3000 / Epoch 002|016, Loss: 24.2, Valid: 90.2%, Time: 33.45s
INFO:ace.ace_trainer:Iteration:   3100 / Epoch 002|016, Loss: 24.2, Valid: 90.7%, Time: 33.81s
INFO:ace.ace_trainer:Iteration:   3200 / Epoch 002|016, Loss: 24.3, Valid: 91.0%, Time: 34.17s
INFO:ace.ace_trainer:Iteration:   3300 / Epoch 002|016, Loss: 24.1, Valid: 91.4%, Time: 34.54s
INFO:ace.ace_trainer:Iteration:   3400 / Epoch 002|016, Loss: 22.5, Valid: 92.1%, Time: 34.92s
INFO:ace.ace_trainer:Iteration:   3500 / Epoch 002|016, Loss: 22.2, Valid: 92.2%, Time: 35.30s
INFO:ace.ace_trainer:Iteration:   3600 / Epoch 003|016, Loss: 23.9, Valid: 93.5%, Time: 35.72s
INFO:ace.ace_trainer:Iteration:   3700 / Epoch 003|016, Loss: 21.6, Valid: 93.6%, Time: 36.10s
INFO:ace.ace_trainer:Iteration:   3800 / Epoch 003|016, Loss: 21.8, Valid: 93.5%, Time: 36.48s
INFO:ace.ace_trainer:Iteration:   3900 / Epoch 003|016, Loss: 21.1, Valid: 93.4%, Time: 36.86s
INFO:ace.ace_trainer:Iteration:   4000 / Epoch 003|016, Loss: 21.7, Valid: 94.0%, Time: 37.24s
INFO:ace.ace_trainer:Iteration:   4100 / Epoch 003|016, Loss: 22.3, Valid: 93.7%, Time: 37.63s
INFO:ace.ace_trainer:Iteration:   4200 / Epoch 003|016, Loss: 21.7, Valid: 94.5%, Time: 38.01s
INFO:ace.ace_trainer:Iteration:   4300 / Epoch 003|016, Loss: 21.6, Valid: 94.5%, Time: 38.38s
INFO:ace.ace_trainer:Iteration:   4400 / Epoch 003|016, Loss: 20.7, Valid: 94.6%, Time: 38.74s
INFO:ace.ace_trainer:Iteration:   4500 / Epoch 003|016, Loss: 21.0, Valid: 94.2%, Time: 39.09s
INFO:ace.ace_trainer:Iteration:   4600 / Epoch 003|016, Loss: 20.8, Valid: 94.5%, Time: 39.44s
INFO:ace.ace_trainer:Iteration:   4700 / Epoch 004|016, Loss: 20.6, Valid: 94.1%, Time: 39.83s
INFO:ace.ace_trainer:Iteration:   4800 / Epoch 004|016, Loss: 20.6, Valid: 94.2%, Time: 40.19s
INFO:ace.ace_trainer:Iteration:   4900 / Epoch 004|016, Loss: 21.2, Valid: 94.2%, Time: 40.54s
INFO:ace.ace_trainer:Iteration:   5000 / Epoch 004|016, Loss: 20.7, Valid: 94.3%, Time: 40.89s
INFO:ace.ace_trainer:Iteration:   5100 / Epoch 004|016, Loss: 20.4, Valid: 94.1%, Time: 41.25s
INFO:ace.ace_trainer:Iteration:   5200 / Epoch 004|016, Loss: 20.2, Valid: 94.4%, Time: 41.60s
INFO:ace.ace_trainer:Iteration:   5300 / Epoch 004|016, Loss: 20.1, Valid: 94.1%, Time: 41.95s
INFO:ace.ace_trainer:Iteration:   5400 / Epoch 004|016, Loss: 20.4, Valid: 94.6%, Time: 42.31s
INFO:ace.ace_trainer:Iteration:   5500 / Epoch 004|016, Loss: 19.1, Valid: 94.6%, Time: 42.66s
INFO:ace.ace_trainer:Iteration:   5600 / Epoch 004|016, Loss: 19.4, Valid: 96.0%, Time: 43.01s
INFO:ace.ace_trainer:Iteration:   5700 / Epoch 004|016, Loss: 18.2, Valid: 95.0%, Time: 43.38s
INFO:ace.ace_trainer:Iteration:   5800 / Epoch 004|016, Loss: 18.8, Valid: 94.6%, Time: 43.74s
INFO:ace.ace_trainer:Iteration:   5900 / Epoch 005|016, Loss: 18.2, Valid: 95.7%, Time: 44.13s
INFO:ace.ace_trainer:Iteration:   6000 / Epoch 005|016, Loss: 18.4, Valid: 95.2%, Time: 44.48s
INFO:ace.ace_trainer:Iteration:   6100 / Epoch 005|016, Loss: 18.4, Valid: 95.7%, Time: 44.84s
INFO:ace.ace_trainer:Iteration:   6200 / Epoch 005|016, Loss: 18.4, Valid: 96.1%, Time: 45.19s
INFO:ace.ace_trainer:Iteration:   6300 / Epoch 005|016, Loss: 18.1, Valid: 95.5%, Time: 45.55s
INFO:ace.ace_trainer:Iteration:   6400 / Epoch 005|016, Loss: 17.9, Valid: 96.3%, Time: 45.92s
INFO:ace.ace_trainer:Iteration:   6500 / Epoch 005|016, Loss: 18.7, Valid: 95.3%, Time: 46.28s
INFO:ace.ace_trainer:Iteration:   6600 / Epoch 005|016, Loss: 17.9, Valid: 95.5%, Time: 46.63s
INFO:ace.ace_trainer:Iteration:   6700 / Epoch 005|016, Loss: 17.4, Valid: 95.8%, Time: 46.99s
INFO:ace.ace_trainer:Iteration:   6800 / Epoch 005|016, Loss: 18.0, Valid: 96.2%, Time: 47.34s
INFO:ace.ace_trainer:Iteration:   6900 / Epoch 005|016, Loss: 17.8, Valid: 96.3%, Time: 47.70s
INFO:ace.ace_trainer:Iteration:   7000 / Epoch 005|016, Loss: 17.8, Valid: 95.7%, Time: 48.05s
INFO:ace.ace_trainer:Iteration:   7100 / Epoch 006|016, Loss: 17.3, Valid: 96.4%, Time: 48.44s
INFO:ace.ace_trainer:Iteration:   7200 / Epoch 006|016, Loss: 17.4, Valid: 96.7%, Time: 48.80s
INFO:ace.ace_trainer:Iteration:   7300 / Epoch 006|016, Loss: 17.3, Valid: 95.9%, Time: 49.16s
INFO:ace.ace_trainer:Iteration:   7400 / Epoch 006|016, Loss: 17.5, Valid: 96.2%, Time: 49.51s
INFO:ace.ace_trainer:Iteration:   7500 / Epoch 006|016, Loss: 18.0, Valid: 96.2%, Time: 49.87s
INFO:ace.ace_trainer:Iteration:   7600 / Epoch 006|016, Loss: 16.7, Valid: 96.3%, Time: 50.23s
INFO:ace.ace_trainer:Iteration:   7700 / Epoch 006|016, Loss: 16.7, Valid: 96.4%, Time: 50.60s
INFO:ace.ace_trainer:Iteration:   7800 / Epoch 006|016, Loss: 16.3, Valid: 96.9%, Time: 50.95s
INFO:ace.ace_trainer:Iteration:   7900 / Epoch 006|016, Loss: 16.6, Valid: 97.0%, Time: 51.31s
INFO:ace.ace_trainer:Iteration:   8000 / Epoch 006|016, Loss: 16.8, Valid: 97.0%, Time: 51.68s
INFO:ace.ace_trainer:Iteration:   8100 / Epoch 006|016, Loss: 16.8, Valid: 96.4%, Time: 52.04s
INFO:ace.ace_trainer:Iteration:   8200 / Epoch 007|016, Loss: 15.8, Valid: 96.9%, Time: 52.45s
INFO:ace.ace_trainer:Iteration:   8300 / Epoch 007|016, Loss: 15.8, Valid: 96.5%, Time: 52.83s
INFO:ace.ace_trainer:Iteration:   8400 / Epoch 007|016, Loss: 15.9, Valid: 97.1%, Time: 53.19s
INFO:ace.ace_trainer:Iteration:   8500 / Epoch 007|016, Loss: 15.9, Valid: 97.8%, Time: 53.56s
INFO:ace.ace_trainer:Iteration:   8600 / Epoch 007|016, Loss: 15.9, Valid: 96.6%, Time: 53.94s
INFO:ace.ace_trainer:Iteration:   8700 / Epoch 007|016, Loss: 15.6, Valid: 96.7%, Time: 54.31s
INFO:ace.ace_trainer:Iteration:   8800 / Epoch 007|016, Loss: 16.2, Valid: 96.6%, Time: 54.67s
INFO:ace.ace_trainer:Iteration:   8900 / Epoch 007|016, Loss: 15.0, Valid: 96.9%, Time: 55.04s
INFO:ace.ace_trainer:Iteration:   9000 / Epoch 007|016, Loss: 15.2, Valid: 96.8%, Time: 55.41s
INFO:ace.ace_trainer:Iteration:   9100 / Epoch 007|016, Loss: 15.6, Valid: 96.6%, Time: 55.78s
INFO:ace.ace_trainer:Iteration:   9200 / Epoch 007|016, Loss: 15.1, Valid: 97.4%, Time: 56.14s
INFO:ace.ace_trainer:Iteration:   9300 / Epoch 007|016, Loss: 15.0, Valid: 97.3%, Time: 56.50s
INFO:ace.ace_trainer:Iteration:   9400 / Epoch 008|016, Loss: 14.6, Valid: 97.1%, Time: 56.89s
INFO:ace.ace_trainer:Iteration:   9500 / Epoch 008|016, Loss: 14.6, Valid: 97.1%, Time: 57.25s
INFO:ace.ace_trainer:Iteration:   9600 / Epoch 008|016, Loss: 14.9, Valid: 97.1%, Time: 57.61s
INFO:ace.ace_trainer:Iteration:   9700 / Epoch 008|016, Loss: 14.3, Valid: 97.0%, Time: 57.96s
INFO:ace.ace_trainer:Iteration:   9800 / Epoch 008|016, Loss: 14.5, Valid: 97.3%, Time: 58.31s
INFO:ace.ace_trainer:Iteration:   9900 / Epoch 008|016, Loss: 14.1, Valid: 97.1%, Time: 58.67s
INFO:ace.ace_trainer:Iteration:  10000 / Epoch 008|016, Loss: 14.4, Valid: 97.0%, Time: 59.02s
INFO:ace.ace_trainer:Iteration:  10100 / Epoch 008|016, Loss: 14.1, Valid: 97.5%, Time: 59.38s
INFO:ace.ace_trainer:Iteration:  10200 / Epoch 008|016, Loss: 13.8, Valid: 97.1%, Time: 59.73s
INFO:ace.ace_trainer:Iteration:  10300 / Epoch 008|016, Loss: 13.7, Valid: 97.2%, Time: 60.09s
INFO:ace.ace_trainer:Iteration:  10400 / Epoch 008|016, Loss: 13.9, Valid: 97.5%, Time: 60.44s
INFO:ace.ace_trainer:Iteration:  10500 / Epoch 008|016, Loss: 13.8, Valid: 97.0%, Time: 60.80s
INFO:ace.ace_trainer:Iteration:  10600 / Epoch 009|016, Loss: 13.1, Valid: 97.3%, Time: 61.19s
INFO:ace.ace_trainer:Iteration:  10700 / Epoch 009|016, Loss: 13.5, Valid: 97.4%, Time: 61.54s
INFO:ace.ace_trainer:Iteration:  10800 / Epoch 009|016, Loss: 13.1, Valid: 97.8%, Time: 61.90s
INFO:ace.ace_trainer:Iteration:  10900 / Epoch 009|016, Loss: 13.1, Valid: 97.7%, Time: 62.25s
INFO:ace.ace_trainer:Iteration:  11000 / Epoch 009|016, Loss: 13.3, Valid: 97.0%, Time: 62.61s
INFO:ace.ace_trainer:Iteration:  11100 / Epoch 009|016, Loss: 12.7, Valid: 97.6%, Time: 62.96s
INFO:ace.ace_trainer:Iteration:  11200 / Epoch 009|016, Loss: 12.5, Valid: 97.6%, Time: 63.33s
INFO:ace.ace_trainer:Iteration:  11300 / Epoch 009|016, Loss: 12.6, Valid: 97.5%, Time: 63.68s
INFO:ace.ace_trainer:Iteration:  11400 / Epoch 009|016, Loss: 12.5, Valid: 97.5%, Time: 64.03s
INFO:ace.ace_trainer:Iteration:  11500 / Epoch 009|016, Loss: 12.6, Valid: 97.5%, Time: 64.39s
INFO:ace.ace_trainer:Iteration:  11600 / Epoch 009|016, Loss: 12.2, Valid: 97.9%, Time: 64.74s
INFO:ace.ace_trainer:Iteration:  11700 / Epoch 009|016, Loss: 12.5, Valid: 97.8%, Time: 65.10s
INFO:ace.ace_trainer:Iteration:  11800 / Epoch 010|016, Loss: 12.2, Valid: 98.0%, Time: 65.49s
INFO:ace.ace_trainer:Iteration:  11900 / Epoch 010|016, Loss: 11.8, Valid: 98.2%, Time: 65.84s
INFO:ace.ace_trainer:Iteration:  12000 / Epoch 010|016, Loss: 11.5, Valid: 97.9%, Time: 66.20s
INFO:ace.ace_trainer:Iteration:  12100 / Epoch 010|016, Loss: 12.0, Valid: 97.4%, Time: 66.55s
INFO:ace.ace_trainer:Iteration:  12200 / Epoch 010|016, Loss: 12.1, Valid: 98.1%, Time: 66.91s
INFO:ace.ace_trainer:Iteration:  12300 / Epoch 010|016, Loss: 11.8, Valid: 97.9%, Time: 67.27s
INFO:ace.ace_trainer:Iteration:  12400 / Epoch 010|016, Loss: 11.5, Valid: 98.0%, Time: 67.62s
INFO:ace.ace_trainer:Iteration:  12500 / Epoch 010|016, Loss: 11.3, Valid: 97.7%, Time: 67.97s
INFO:ace.ace_trainer:Iteration:  12600 / Epoch 010|016, Loss: 11.3, Valid: 97.9%, Time: 68.33s
INFO:ace.ace_trainer:Iteration:  12700 / Epoch 010|016, Loss: 11.2, Valid: 97.9%, Time: 68.69s
INFO:ace.ace_trainer:Iteration:  12800 / Epoch 010|016, Loss: 11.4, Valid: 98.2%, Time: 69.04s
INFO:ace.ace_trainer:Iteration:  12900 / Epoch 011|016, Loss: 11.1, Valid: 98.0%, Time: 69.44s
INFO:ace.ace_trainer:Iteration:  13000 / Epoch 011|016, Loss: 10.7, Valid: 98.2%, Time: 69.81s
INFO:ace.ace_trainer:Iteration:  13100 / Epoch 011|016, Loss: 11.0, Valid: 98.2%, Time: 70.17s
INFO:ace.ace_trainer:Iteration:  13200 / Epoch 011|016, Loss: 10.7, Valid: 98.2%, Time: 70.52s
INFO:ace.ace_trainer:Iteration:  13300 / Epoch 011|016, Loss: 10.7, Valid: 97.7%, Time: 70.88s
INFO:ace.ace_trainer:Iteration:  13400 / Epoch 011|016, Loss: 10.7, Valid: 98.1%, Time: 71.23s
INFO:ace.ace_trainer:Iteration:  13500 / Epoch 011|016, Loss: 10.4, Valid: 97.9%, Time: 71.59s
INFO:ace.ace_trainer:Iteration:  13600 / Epoch 011|016, Loss: 10.3, Valid: 98.2%, Time: 71.94s
INFO:ace.ace_trainer:Iteration:  13700 / Epoch 011|016, Loss: 10.2, Valid: 98.0%, Time: 72.30s
INFO:ace.ace_trainer:Iteration:  13800 / Epoch 011|016, Loss: 10.3, Valid: 98.4%, Time: 72.65s
INFO:ace.ace_trainer:Iteration:  13900 / Epoch 011|016, Loss: 10.3, Valid: 98.4%, Time: 73.00s
INFO:ace.ace_trainer:Iteration:  14000 / Epoch 011|016, Loss: 10.3, Valid: 98.0%, Time: 73.36s
INFO:ace.ace_trainer:Iteration:  14100 / Epoch 012|016, Loss: 9.7, Valid: 98.4%, Time: 73.76s
INFO:ace.ace_trainer:Iteration:  14200 / Epoch 012|016, Loss: 9.6, Valid: 98.6%, Time: 74.12s
INFO:ace.ace_trainer:Iteration:  14300 / Epoch 012|016, Loss: 9.5, Valid: 98.6%, Time: 74.47s
INFO:ace.ace_trainer:Iteration:  14400 / Epoch 012|016, Loss: 9.5, Valid: 98.6%, Time: 74.82s
INFO:ace.ace_trainer:Iteration:  14500 / Epoch 012|016, Loss: 9.5, Valid: 97.9%, Time: 75.18s
INFO:ace.ace_trainer:Iteration:  14600 / Epoch 012|016, Loss: 9.5, Valid: 98.7%, Time: 75.53s
INFO:ace.ace_trainer:Iteration:  14700 / Epoch 012|016, Loss: 9.5, Valid: 98.2%, Time: 75.89s
INFO:ace.ace_trainer:Iteration:  14800 / Epoch 012|016, Loss: 9.5, Valid: 98.5%, Time: 76.24s
INFO:ace.ace_trainer:Iteration:  14900 / Epoch 012|016, Loss: 9.2, Valid: 98.8%, Time: 76.59s
INFO:ace.ace_trainer:Iteration:  15000 / Epoch 012|016, Loss: 9.1, Valid: 99.1%, Time: 76.95s
INFO:ace.ace_trainer:Iteration:  15100 / Epoch 012|016, Loss: 9.3, Valid: 98.1%, Time: 77.30s
INFO:ace.ace_trainer:Iteration:  15200 / Epoch 012|016, Loss: 9.1, Valid: 98.6%, Time: 77.66s
INFO:ace.ace_trainer:Iteration:  15300 / Epoch 013|016, Loss: 8.5, Valid: 98.6%, Time: 78.05s
INFO:ace.ace_trainer:Iteration:  15400 / Epoch 013|016, Loss: 8.4, Valid: 98.5%, Time: 78.40s
INFO:ace.ace_trainer:Iteration:  15500 / Epoch 013|016, Loss: 8.3, Valid: 98.7%, Time: 78.76s
INFO:ace.ace_trainer:Iteration:  15600 / Epoch 013|016, Loss: 8.4, Valid: 98.7%, Time: 79.11s
INFO:ace.ace_trainer:Iteration:  15700 / Epoch 013|016, Loss: 8.3, Valid: 98.8%, Time: 79.47s
INFO:ace.ace_trainer:Iteration:  15800 / Epoch 013|016, Loss: 8.5, Valid: 98.9%, Time: 79.83s
INFO:ace.ace_trainer:Iteration:  15900 / Epoch 013|016, Loss: 8.3, Valid: 98.2%, Time: 80.20s
INFO:ace.ace_trainer:Iteration:  16000 / Epoch 013|016, Loss: 8.2, Valid: 98.6%, Time: 80.56s
INFO:ace.ace_trainer:Iteration:  16100 / Epoch 013|016, Loss: 8.2, Valid: 98.7%, Time: 80.92s
INFO:ace.ace_trainer:Iteration:  16200 / Epoch 013|016, Loss: 8.0, Valid: 98.5%, Time: 81.29s
INFO:ace.ace_trainer:Iteration:  16300 / Epoch 013|016, Loss: 8.0, Valid: 99.1%, Time: 81.66s
INFO:ace.ace_trainer:Iteration:  16400 / Epoch 014|016, Loss: 8.1, Valid: 98.4%, Time: 82.06s
INFO:ace.ace_trainer:Iteration:  16500 / Epoch 014|016, Loss: 7.7, Valid: 98.2%, Time: 82.41s
INFO:ace.ace_trainer:Iteration:  16600 / Epoch 014|016, Loss: 7.4, Valid: 98.5%, Time: 82.77s
INFO:ace.ace_trainer:Iteration:  16700 / Epoch 014|016, Loss: 7.7, Valid: 99.1%, Time: 83.12s
INFO:ace.ace_trainer:Iteration:  16800 / Epoch 014|016, Loss: 7.7, Valid: 98.9%, Time: 83.48s
INFO:ace.ace_trainer:Iteration:  16900 / Epoch 014|016, Loss: 7.5, Valid: 98.3%, Time: 83.83s
INFO:ace.ace_trainer:Iteration:  17000 / Epoch 014|016, Loss: 7.2, Valid: 98.6%, Time: 84.19s
INFO:ace.ace_trainer:Iteration:  17100 / Epoch 014|016, Loss: 7.5, Valid: 98.7%, Time: 84.54s
INFO:ace.ace_trainer:Iteration:  17200 / Epoch 014|016, Loss: 7.2, Valid: 98.4%, Time: 84.89s
INFO:ace.ace_trainer:Iteration:  17300 / Epoch 014|016, Loss: 6.9, Valid: 98.3%, Time: 85.25s
INFO:ace.ace_trainer:Iteration:  17400 / Epoch 014|016, Loss: 7.1, Valid: 98.4%, Time: 85.60s
INFO:ace.ace_trainer:Iteration:  17500 / Epoch 014|016, Loss: 6.8, Valid: 98.9%, Time: 85.96s
INFO:ace.ace_trainer:Iteration:  17600 / Epoch 015|016, Loss: 6.6, Valid: 98.6%, Time: 86.35s
INFO:ace.ace_trainer:Iteration:  17700 / Epoch 015|016, Loss: 6.8, Valid: 98.9%, Time: 86.71s
INFO:ace.ace_trainer:Iteration:  17800 / Epoch 015|016, Loss: 6.6, Valid: 98.5%, Time: 87.06s
INFO:ace.ace_trainer:Iteration:  17900 / Epoch 015|016, Loss: 6.4, Valid: 98.2%, Time: 87.42s
INFO:ace.ace_trainer:Iteration:  18000 / Epoch 015|016, Loss: 6.3, Valid: 99.0%, Time: 87.77s
INFO:ace.ace_trainer:Iteration:  18100 / Epoch 015|016, Loss: 6.0, Valid: 98.9%, Time: 88.13s
INFO:ace.ace_trainer:Iteration:  18200 / Epoch 015|016, Loss: 6.0, Valid: 98.6%, Time: 88.48s
INFO:ace.ace_trainer:Iteration:  18300 / Epoch 015|016, Loss: 5.7, Valid: 98.7%, Time: 88.84s
INFO:ace.ace_trainer:Iteration:  18400 / Epoch 015|016, Loss: 5.5, Valid: 98.6%, Time: 89.19s
INFO:ace.ace_trainer:Iteration:  18500 / Epoch 015|016, Loss: 5.1, Valid: 98.7%, Time: 89.54s
INFO:ace.ace_trainer:Iteration:  18600 / Epoch 015|016, Loss: 4.7, Valid: 98.5%, Time: 89.90s
INFO:ace.ace_trainer:Iteration:  18700 / Epoch 015|016, Loss: 3.7, Valid: 98.6%, Time: 90.26s
INFO:ace.ace_trainer:Saved trained head weights to: data_example/room1/ace/ace.pt
INFO:ace.ace_trainer:Done without errors. Creating buffer time: 21.6 seconds. Training time: 68.8 seconds. Total time: 90.4 seconds.

point cloud:   0%|          | 0/247 [00:00<?, ?it/s]
point cloud:   1%|          | 3/247 [00:00<00:13, 18.76it/s]
point cloud:   2%|▏         | 5/247 [00:00<00:13, 17.54it/s]
point cloud:   3%|▎         | 7/247 [00:00<00:14, 16.50it/s]
point cloud:   4%|▍         | 10/247 [00:00<00:12, 19.26it/s]
point cloud:   5%|▍         | 12/247 [00:00<00:15, 15.59it/s]
point cloud:   6%|▌         | 15/247 [00:00<00:13, 17.81it/s]
point cloud:   7%|▋         | 18/247 [00:00<00:11, 19.38it/s]
point cloud:   8%|▊         | 20/247 [00:01<00:16, 13.75it/s]
point cloud:   9%|▉         | 23/247 [00:01<00:13, 16.00it/s]
point cloud:  11%|█         | 26/247 [00:01<00:12, 17.77it/s]
point cloud:  12%|█▏        | 29/247 [00:01<00:11, 18.91it/s]
point cloud:  13%|█▎        | 32/247 [00:01<00:10, 19.98it/s]
point cloud:  14%|█▍        | 35/247 [00:01<00:10, 20.85it/s]
point cloud:  15%|█▌        | 38/247 [00:02<00:16, 12.35it/s]
point cloud:  17%|█▋        | 41/247 [00:02<00:13, 14.78it/s]
point cloud:  18%|█▊        | 44/247 [00:02<00:11, 17.18it/s]
point cloud:  19%|█▉        | 47/247 [00:02<00:10, 18.97it/s]
point cloud:  20%|██        | 50/247 [00:02<00:09, 20.12it/s]
point cloud:  21%|██▏       | 53/247 [00:02<00:09, 20.60it/s]
point cloud:  23%|██▎       | 56/247 [00:03<00:09, 21.14it/s]
point cloud:  24%|██▍       | 59/247 [00:03<00:08, 21.92it/s]
point cloud:  25%|██▌       | 62/247 [00:03<00:08, 22.98it/s]
point cloud:  26%|██▋       | 65/247 [00:03<00:07, 23.53it/s]
point cloud:  28%|██▊       | 68/247 [00:03<00:07, 23.56it/s]
point cloud:  29%|██▊       | 71/247 [00:03<00:07, 23.51it/s]
point cloud:  30%|██▉       | 74/247 [00:03<00:07, 23.16it/s]
point cloud:  31%|███       | 77/247 [00:03<00:07, 23.41it/s]
point cloud:  32%|███▏      | 80/247 [00:04<00:18,  9.19it/s]
point cloud:  34%|███▎      | 83/247 [00:04<00:14, 11.32it/s]
point cloud:  35%|███▍      | 86/247 [00:05<00:11, 13.43it/s]
point cloud:  36%|███▌      | 89/247 [00:05<00:10, 15.36it/s]
point cloud:  37%|███▋      | 92/247 [00:05<00:09, 17.03it/s]
point cloud:  38%|███▊      | 95/247 [00:05<00:08, 18.74it/s]
point cloud:  40%|███▉      | 98/247 [00:05<00:07, 19.88it/s]
point cloud:  41%|████      | 101/247 [00:05<00:07, 20.83it/s]
point cloud:  42%|████▏     | 104/247 [00:05<00:06, 21.72it/s]
point cloud:  43%|████▎     | 107/247 [00:05<00:06, 22.09it/s]
point cloud:  45%|████▍     | 110/247 [00:06<00:06, 22.33it/s]
point cloud:  46%|████▌     | 113/247 [00:06<00:05, 22.77it/s]
point cloud:  47%|████▋     | 116/247 [00:06<00:05, 23.94it/s]
point cloud:  48%|████▊     | 119/247 [00:06<00:05, 25.02it/s]
point cloud:  49%|████▉     | 122/247 [00:06<00:05, 24.71it/s]
point cloud:  51%|█████     | 125/247 [00:06<00:05, 24.28it/s]
point cloud:  52%|█████▏    | 128/247 [00:06<00:04, 24.22it/s]
point cloud:  53%|█████▎    | 131/247 [00:06<00:04, 24.14it/s]
point cloud:  54%|█████▍    | 134/247 [00:07<00:04, 24.13it/s]
point cloud:  55%|█████▌    | 137/247 [00:07<00:04, 23.74it/s]
point cloud:  57%|█████▋    | 140/247 [00:07<00:04, 23.30it/s]
point cloud:  58%|█████▊    | 143/247 [00:07<00:04, 24.10it/s]
point cloud:  59%|█████▉    | 146/247 [00:07<00:04, 25.10it/s]
point cloud:  60%|██████    | 149/247 [00:07<00:03, 25.37it/s]
point cloud:  62%|██████▏   | 152/247 [00:07<00:03, 24.91it/s]
point cloud:  63%|██████▎   | 155/247 [00:07<00:03, 24.33it/s]
point cloud:  64%|██████▍   | 158/247 [00:08<00:03, 24.08it/s]
point cloud:  65%|██████▌   | 161/247 [00:09<00:14,  5.90it/s]
point cloud:  66%|██████▋   | 164/247 [00:09<00:10,  7.67it/s]
point cloud:  68%|██████▊   | 167/247 [00:09<00:08,  9.74it/s]
point cloud:  69%|██████▉   | 170/247 [00:09<00:06, 11.86it/s]
point cloud:  70%|███████   | 173/247 [00:09<00:05, 13.75it/s]
point cloud:  71%|███████▏  | 176/247 [00:10<00:04, 15.39it/s]
point cloud:  72%|███████▏  | 179/247 [00:10<00:04, 16.71it/s]
point cloud:  74%|███████▎  | 182/247 [00:10<00:03, 18.17it/s]
point cloud:  75%|███████▍  | 185/247 [00:10<00:03, 19.40it/s]
point cloud:  76%|███████▌  | 188/247 [00:10<00:02, 20.18it/s]
point cloud:  77%|███████▋  | 191/247 [00:10<00:02, 20.95it/s]
point cloud:  79%|███████▊  | 194/247 [00:10<00:02, 21.22it/s]
point cloud:  80%|███████▉  | 197/247 [00:10<00:02, 22.01it/s]
point cloud:  81%|████████  | 200/247 [00:11<00:02, 22.20it/s]
point cloud:  82%|████████▏ | 203/247 [00:11<00:01, 22.32it/s]
point cloud:  83%|████████▎ | 206/247 [00:11<00:01, 22.48it/s]
point cloud:  85%|████████▍ | 209/247 [00:11<00:01, 22.53it/s]
point cloud:  86%|████████▌ | 212/247 [00:11<00:01, 22.83it/s]
point cloud:  87%|████████▋ | 215/247 [00:11<00:01, 23.09it/s]
point cloud:  88%|████████▊ | 218/247 [00:11<00:01, 23.11it/s]
point cloud:  89%|████████▉ | 221/247 [00:12<00:01, 23.41it/s]
point cloud:  91%|█████████ | 224/247 [00:12<00:00, 23.73it/s]
point cloud:  92%|█████████▏| 227/247 [00:12<00:00, 23.73it/s]
point cloud:  93%|█████████▎| 230/247 [00:12<00:00, 23.54it/s]
point cloud:  94%|█████████▍| 233/247 [00:12<00:00, 23.81it/s]
point cloud:  96%|█████████▌| 236/247 [00:12<00:00, 23.69it/s]
point cloud:  97%|█████████▋| 239/247 [00:12<00:00, 24.11it/s]
point cloud:  98%|█████████▊| 242/247 [00:12<00:00, 24.21it/s]
point cloud:  99%|█████████▉| 245/247 [00:13<00:00, 24.19it/s]
point cloud: 100%|██████████| 247/247 [00:13<00:00, 18.84it/s]
FutureWarning: Importing from timm.models.layers is deprecated, please import via timm.layers
FutureWarning: Importing from timm.models.hub is deprecated, please import via timm.models
FutureWarning: Importing from timm.models.registry is deprecated, please import via timm.models
FutureWarning: Importing from timm.models.helpers is deprecated, please import via timm.models
Traceback (most recent call last):
  File "/app/demo.py", line 91, in <module>
    main(args)
  File "/app/demo.py", line 40, in main
    controller.get_semantic_memory()
  File "/app/dovsg/controller.py", line 862, in get_semantic_memory
    semantic_memory = RamGroundingDinoSAM2ClipDataset(
  File "/app/dovsg/memory/ram_groundingdino_sam2_clip_semantic_memory.py", line 34, in __init__
    self.mygroundingdino_sam2 = MyGroundingDINOSAM2(
TypeError: __init__() got an unexpected keyword argument 'device'

ERROR conda.cli.main_run:execute(127): `conda run python demo.py --tags room1 --preprocess --debug` failed. (See above for error)