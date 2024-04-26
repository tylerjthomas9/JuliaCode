# JuliaCode

This is the code used to generate the [JuliaCode](https://huggingface.co/datasets/tylerjthomas9/JuliaCode) dataset on Huggingface. There are currently three different scripts that break down the process of creating the dataset. This is a rough POC, so there is a lot of room for improvement.

1. `download_code.jl`: Download all code from the Julia General registry. This takes a couple of hours to run when you are first collecting the data.
2. `create_dataset.jl`: Parse all of the packages and create a jsonl file with the text for training language models.
3. `upload_dataset.jl`: Upload the dataset to HuggingFace.


