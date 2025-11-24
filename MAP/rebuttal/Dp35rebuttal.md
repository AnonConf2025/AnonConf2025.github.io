**Dear Reviewer Dp35,**

We sincerely thank you for your thoughtful review and the time you dedicated to evaluating our work. We are encouraged by your positive assessment of the paper’s soundness, presentation, and motivation. We particularly appreciate your recognition of our comprehensive results and the clarity of our writing.

We have carefully considered your constructive feedback and have updated our manuscript accordingly. Below, we address your specific questions regarding training costs, the theoretical basis of gradient disparity, and the discussion of limitations.

**Q1. Comparison of finetuning costs with baseline methods.**

> *Are the compared baselines all requiring the similar finetuning costs? It would be more meaningful to include the comparison on the training costs to obtain the pruned structure.*

**A1:**
Thank you for raising this important point regarding fair comparison. We confirm that our method incurs **comparable, if not lower,** total training costs relative to the primary baseline, **NOSE**.

To be precise, the computational cost consists of two phases: structural selection and fine-tuning.
1.  **Structural Selection:** NOSE determines pruning locations based on metrics calculated over the **full training set**. In contrast, our method constructs the MAP predictor and determines pruning locations using only a **small calibration dataset**, making our search phase highly efficient.
2.  **Fine-tuning:** After the structure is determined, both methods employ the exact same schedule of **400 epochs** for fine-tuning the pruned model.

Therefore, the performance gains reported in our paper are derived from the effectiveness of our pruning criteria rather than an increased computational budget. We have clarified these details in the **Experiment Setup** section of the revised manuscript to explicitly state that the training budgets are aligned.

**Q2. The origin of Gradient Disparity.**

> *I wonder why the gradient disparity is observed on the additional learnable layer importance added by author, rather than on the native ViT behavior...*

**A2:**
This is a very insightful question. We agree that distinguishing between artifacts of the method and intrinsic model properties is crucial.

In our revised manuscript (specifically **Appendix H**), we provide a theoretical derivation proving that the gradient disparity is **intrinsic to the ViT architecture**, and the learnable importance factors merely act as "probes" that reveal this underlying behavior.

The disparity arises from two fundamental structural differences between the Activation (GELU) path and the Attention path:

1.  **Dimensionality Amplification (Lemma 1):** The GELU layer expands the hidden dimension by a factor of 4 ($4d$) compared to the attention output ($d$). Consequently, the gradient for the activation path aggregates four times more terms.
2.  **Activation Variance Disparity (Lemma 2):** Attention outputs are constrained by LayerNorm and Softmax, resulting in a distribution close to $\mathcal{N}(0,1)$. In contrast, GELU activations in the FFN branch are unnormalized and exhibit heavy-tailed statistics with significantly larger variance ($M_{\mathcal G} \gg M_{\mathcal A}$).

**Theorem 4** in our revision synthesizes these factors to show that the ratio of expected gradient energies is:
$$ \frac{\mathbb E\|\nabla_{\hat m^g}\|^2}{\mathbb E\|\nabla_{\hat m^a}\|^2} \approx 4 \times \frac{M_{\mathcal G}}{M_{\mathcal A}} $$
Since $M_{\mathcal G} \gg M_{\mathcal A}$, the gradient magnitude for the activation path is mathematically guaranteed to dominate the attention path by 1–2 orders of magnitude, regardless of the specific pruning method used. You can also find our detailed proof of this phenomenon on this webpage [Gradient Disparity](https://anonconf2025.github.io/MathProof/prof4.html).

**Q3. Discussion of Limitations.**

> *The paper also didn't include a dedicated limitation discussion.*

**A3:**
We apologize for this oversight and thank you for pointing it out. We have added a dedicated **Limitations** section in the revised paper. In summary, we discuss:
1.  **Generalization of the MAP Predictor:** While our polynomial MAP predictor is highly effective for standard classification, its behavior in more complex, multi-modal scenarios requires further validation.
2.  **Architectural Scope:** Our current derivation and experiments focus on standard ViT architectures. The application of this method to heterogeneous Transformer variants (e.g., hierarchical models) remains a subject for future work.

***

We deeply appreciate your commitment to helping us enhance the quality and clarity of our research. We view you as a collaborative partner in this process rather than merely a reviewer. We hope these responses and the corresponding revisions satisfactorily address your concerns. Should you have any further questions, we would be honored to answer them.

Best regards,

**The Authors**