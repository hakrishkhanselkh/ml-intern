#!/bin/bash
# Submit all PostTrainBench jobs for hf_agent
# Usage: bash posttrain-bench/slurm/submit_all.sh [hours] [agent_config]
# Example: bash posttrain-bench/slurm/submit_all.sh 10 claude-opus-4-6

set -euo pipefail

HOURS="${1:-10}"
AGENT_CONFIG="${2:-claude-opus-4-6}"

models=(
    "Qwen/Qwen3-1.7B-Base"
    "Qwen/Qwen3-4B-Base"
    "HuggingFaceTB/SmolLM3-3B-Base"
    "google/gemma-3-4b-pt"
)

evals=(
    "aime2025"
    "arenahardwriting"
    "bfcl"
    "gpqamain"
    "gsm8k"
    "healthbench"
    "humaneval"
)

echo "Submitting ${#models[@]} models x ${#evals[@]} evals = $(( ${#models[@]} * ${#evals[@]} )) jobs"
echo "Hours: $HOURS | Config: $AGENT_CONFIG"
echo ""

for model in "${models[@]}"; do
    for eval in "${evals[@]}"; do
        echo "  $model on $eval"
        sbatch posttrain-bench/slurm/submit.sbatch "$eval" hf_agent "$model" "$HOURS" "$AGENT_CONFIG"
        sleep 2
    done
done

echo ""
echo "All jobs submitted. Monitor with: myjobs"
