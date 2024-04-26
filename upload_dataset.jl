using PythonCall

datasets = pyimport("datasets")
dataset = datasets.load_dataset("json", data_files="./train.jsonl")
dataset.push_to_hub("tylerjthomas9/JuliaCode")
