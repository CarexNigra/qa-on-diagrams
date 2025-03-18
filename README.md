# Evaluating Performance of Context Understanding with Vision Support

## Table of Contents
- [Task Description](#task-description)
- [Dataset Construction](#dataset-construction)
- [Experiment Setup](#experiment-setup)
- [Evaluation Methodology](#evaluation-methodology)
- [Results](#results)
- [Interpretation](#interpretation)
- [Conclusion](#conclusion)

---

## Task Description

The objective of this study is to evaluate the performance of frontier multimodal large language models that support vision (image modality). Specifically, we aim to assess whether providing both textual and visual context improves the model’s ability to understand and interpret information.

The experiment is designed as follows:

1. A set of tasks is created where each task consists of a user query and an associated context.
2. The user query is a question that needs to be answered by the model given the context (without using any prior knowledge on the subject).
3. Two types of tests are performed:
   - Text-only context: The model receives text extracted from or associated with images (e.g., OCR output, captions, titles).
   - Text + image context: The model receives both text and the original image as inputs.
4. The goal is to determine if the inclusion of the image enhances the model’s ability to answer questions accurately, leveraging visual and spatial information.

---

## Dataset Construction

The dataset used in this study was derived from the [FlowLearn dataset](https://github.com/jo-pan/flowlearn). FlowLearn contains complex scientific flowcharts, which primarily represent textual information arranged in a structured spatial order. The dataset is enriched with annotations (titles, captions) and OCR.

The dataset was prepared through the following steps:

1. A subset of 100 images was randomly sampled from FlowLearn.
2. Each image was associated with the following textual information:
   - Caption: A brief description of the image.
   - Title: The title associated with the image.
   - OCR Texts: Text detected within the image using an Optical Character Recognition (OCR) tool.
3. The OpenAI GPT-4o model was used to generate two pairs of question-answer pairs per image.

The following prompt was used to instruct the model to generate context-sensitive Q&A pairs:
```
"Analyze the image and its metadata to generate two questions and answers
considering the spatial arrangement of the text.
Provide the result in JSON format, where each pair of question and answer
is a dict, and the whole response is a list of dicts.
Avoid questions that require solely the description of elements of the
image.
Text data should be used as much as possible.
Do not use, either in question or in answer, any visual elements (arrows,
shapes, lines) of the schema, their color, style, or shape.
Do not mention the image/schema/figure as a whole.
To answer a question, it should be sufficient to look at 
```

The final dataset consisted of 100 images and 200 question-answer pairs, each linked to its respective metadata.

---

## Experiment Setup

The main experiment was conducted using three state-of-the-art multimodal models:

1. [GPT-4o](https://github.com/marketplace/models/azure-openai/gpt-4o)
2. [Qwen-VL-Max](https://github.com/QwenLM/Qwen-VL)
3. [Claude-3.5-Sonnet](https://gist.github.com/cedrickchee/e3641c126d1aae0b8701afd08c83fd31)

Each model was tested under two different conditions:

- Text-only input: The model received only the concatenated textual metadata (caption, title, OCR text).
- Text + image input: The model received both the textual metadata and the corresponding image.

To ensure consistency, the following prompts were used for inference:

### **Prompts Used for Answer Generation**

1. System prompt (same for all models)
```
"You are an assistant that answers questions based on the given text and
*optional* image as context.
If it's indicated that an image is provided, then pay much more attention
to the image to capture text and structure from there.
Do not use your prior knowledge about the subject matter. Base your answer
only on the information provided in the input.
If you cannot answer the question based on the provided context, respond
with `no answer`
. Do not create vague explanations.
"
```

2. Task prompt for text-only Input
```
"Given the context with a text description of a diagram, create a short
answer for the following question: {}"
```

3. Task prompt for text + image Input
```
"Given the context with a text description of a diagram and the *diagram
image itself*, create a short answer for the following question: {}"
```

Each model was run on the same set of inputs to ensure fair comparison.

Each model was run on the same dataset to ensure **fair comparisons**.

---

## Evaluation Methodology

To measure the correctness and quality of the answers, we used [Ragas](https://docs.ragas.io/en/v0.1.21/index.html), an evaluation framework for assessing LLM-generated answers.

The evaluation metric used was [Answer Correctness Score](https://docs.ragas.io/en/v0.1.21/concepts/metrics/answer_correctness.html) which measures whether the generated answer accurately reflects the provided context. Higher scores indicate better
correctness.

The final evaluation pipeline followed these steps:

1. Collect model-generated answers for both **text-only** and **text + image** contexts.
2. Run the answers through Ragas evaluation metrics.
3. Compare correctness scores between the two input modalities.
4. Conduct a paired t-test to assess statistical significance.
5. Analyze the improvements or inconsistencies across different models.

---

## Results

| Model           | Text Score | Text + Image Score | Uplift (%) | t-statistic | p-value | Mean Diff | Confidence Interval (95%) |
|---------------|------------|-------------------|------------|-------------|---------|------------|-------------------------|
| **GPT-4o**    | 0.4356     | 0.6864            | +57.6%     | -6.95       | 3.85e-10 | 0.251      | (0.19, 0.312)          |
| **Claude-3.5**| 0.3759     | 0.5166            | +37.5%     | -4.76       | 6.45e-06 | 0.141      | (0.095, 0.187)         |
| **Qwen-VL-Max** | 0.4073   | 0.6443            | +58.2%     | -7.51       | 2.58e-11 | 0.237      | (0.177, 0.297)         |

---

## Interpretation

* All three models exhibited a statistically significant improvement when provided with both
text and image context.
* GPT-4o and Qwen-VL-Max showed the highest relative uplift (+57.6% and +58.2%,
respectively), suggesting these models effectively utilize visual context.
* Claude-3.5-Sonnet also improved significantly (+37.5% uplift) but showed a smaller
absolute improvement compared to the other models.
* Paired t-tests confirm that the performance gains are statistically significant (p-values <
0.05 for all models), rejecting the null hypothesis that image context does not improve
performance.
* The confidence intervals indicate the true mean uplift range for each model with 95%
certainty, reinforcing the robustness of these improvements.

---

## Conclusion
This study demonstrates that providing both textual and visual context significantly enhances
the ability of multimodal LLMs to understand and generate correct answers. The results confirm
that:
* GPT-4o and Qwen-VL-Max show the highest gains when incorporating images, suggesting stronger visual reasoning capabilities.
* Claude-3.5-Sonnet also benefits from visual input, but to a slightly lesser extent.
* All improvements are statistically significant, which confirms that these results are not
due to random variation but a real, meaningful enhancement in model performance.
* Future research could explore:
    * Scaling the dataset for broader validation or manual creation of more specific dataset
    * Extending to additional multimodal models.
    * Qualitative analysis to assess types of questions that benefit most from vision input.

This experiment highlights the critical role of visual context in improving LLMs’ comprehension
and reasoning capabilities, making a strong case for multimodal AI in practical applications