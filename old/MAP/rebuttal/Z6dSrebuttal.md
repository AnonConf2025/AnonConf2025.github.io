**Dear Reviewer Z6dS,**

We sincerely thank you for your detailed and constructive feedback. We are encouraged by your recognition of our work's strengths, particularly the **comprehensive experimental results**, the **novel study of activation-layer redundancy**, and the **strong empirical performance** compared to previous depth pruning methods.

We have carefully addressed your concerns regarding the presentation logic, the motivation for activation pruning, and the theoretical grounding of the Model Accuracy Predictor (MAP). Below, we provide detailed responses and references to our revised manuscript and supplementary webpages.

**Q1. Clarification of $k$ in Eq. 3.**

> *Although I guess $k$ in eq3 means the sparsity constraint of the layer/model, but the author didn't define $k$ in the text.*

**A1:**
We apologize for the omission. You are correct: $k$ denotes the **sparsity constraint**, specifically the total number of layers (sum of attention and activation layers) to be retained after pruning. We have added this definition explicitly in the revised manuscript.

**Q2. Logic Flow: From Observations to Methodology.**

> *I'm not sure about the meaning of section3... How the observation leads into the intuition or motivation of the methodology?*

**A2:**
Thank you for pointing out the need for a stronger logical connection. We have restructured Section 3 and Section 4 to establish a clear causal chain: **Observations $\to$ Challenges $\to$ Design Principles $\to$ Method Alignment**.

1.  **Observations (Heterogeneity):**
    *   **Gradient Disparity:** The attention layers and activation function layers exhibit significant differences in gradient scales during backpropagation, which can lead to biased importance estimations and suboptimal pruning decisions when employing training-based search strategies.
    *   **Recovery Asymmetry:** Attention layer pruning causes moderate initial accuracy drops but requires extensive retraining for recovery, while activation function layer pruning results in severe initial degradation (often $\geq$ 90\%) but enables rapid recovery during fine-tuning.
2.  **Challenges (Failure of Naive Methods):**
    *   **Failure of Gradient-based Pruning Metrics:** Given the unique training dynamics in ViTs, using gradients to evaluate the importance of these two types of layers results in significantly biased outcomes, with all attention layers constantly outweighing linear layers.
    *   **Failure of Short-sighted Pruning Metrics.:** The substantial asymmetry in accuracy dynamics between these two types of components in ViTs renders conventional handcrafted pruning metrics ineffective for joint pruning, as these metrics typically reflect only immediate post-pruning accuracy retention.
3.  **Design Principles:**
    *   **Principle 1:** Avoid direct cross-type layer importance comparison, especially when using gradient-based metrics.
    *   **Principle 2:** Layer importance should be evaluated based on the final accuracy of fine-tuned pruned ViTs, rather than the immediate accuracy after pruning.
4.  **Alignment with Methodology:**
   The Stage 1 of our method is further divided into two steps: pruning budget allocation (Step 1) and specific redundant layer removal (Step 2).
       - Step 1 utilizes a model accuracy predictor, to help establish the optimal quantities of attention and activation function layers to prune based on the accuracy recovered after fine-tuning, directly implementing Principle 2. 
       -  Importantly, Step 1 focuses solely on determining the pruning quantities for each layer type, avoiding cross-type importance comparisons, thus adhering to Principle 1. 
       -   Step 2 employs gradient-based methods only within homogeneous layer groups, i.e., either attention or activation function layers, ensuring compliance with Principle 1 throughout the pruning process.

**Q3. Presentation of Part 1 and Motivation for Activation Pruning.**

> *The writeup of part 1 is a little messy... there is no motivation supporting why we are considering pruning activations.*

**A3:**
We have thoroughly rewritten Part 1 and the Introduction to clarify the motivation.

**1. Structural Revision:**
We have reorganized the **Introduction** into five focused segments that build logically:
- **ViT compression context** - establishing the computational challenges of ViTs
- **Challenge of depth pruning** - contrasting depth versus width pruning approaches and highlighting depth pruning's accuracy recovery difficulties despite superior speedup potential
- **Joint depth pruning matters** - denoting joint depth pruning with cross-layer heterogeneity management can address the challenge of depth pruning
- **Dimension mismatch hinders joint depth pruning** - further defining the technical barrier that prevents effective joint depth pruning of attention and linear layers
- **Threefold contributions** - presenting our final solution to tackle dimension mismatch along with the consequent innovations and SOTA results

**2. Motivation for Activation Pruning :**
The core motivation to prune activation function layer is **dimension mismatch.**  
- `Definition.` In vision Transformers (ViTs)，dimension mismatch occurs when removing linear layers from a Feed-Forward Network (FFN) block without proper adjustment of the network architecture, which disrupts the dimensional compatibility between consecutive layers. As visualized in **Figure 3** in our uploaded revised version, dimension mismatch manifests in two primary scenarios:
  - When the first linear layer of an FFN block is pruned, the output tensor from the previous attention layer cannot be properly processed by the remaining second linear layer due to dimensional incompatibility.
  - When the second linear layer of an FFN block is pruned, the output tensor fails to propagate through subsequent attention layers.
- `Negative impact.` Dimension mismatch directly hinders joint depth pruning since such mismatch leads that the pruned ViTs are completely unworkable. 
- `Method.` To perform joint pruning in depth while avoiding dimension mismatch, we firstly propose the pruning of activation function layers in ViTs. By reducing the redundancy of these nonlinearity, instead of directly pruning linear layers in ViTs, the depths of ViTs are naturally reduced without incurring dimension mismatch.   


**Q4. Theoretical Grounding of MAP.**

> *The MAP polynomial approximation, though effective, feels heuristic without theoretical grounding.*

**A4:**
We respectfully clarify that MAP is **not heuristic**; it is supported by a rigorous mathematical framework that establishes a complete logical closure for our method. As detailed in **Appendix H** and the [Theoretical Foundations webpage](https://anonconf2025.github.io/MathProof/overview.html), Theorems 1–3 collectively construct a mathematical guarantee for MAP’s effectiveness:

1.  **Existence of Solution (Theorem 1 — Well-posedness):**
    We first establish that the pruning-ratio optimization problem is mathematically well-posed. Since the pruning domain $\mathcal{D}_k$ is a finite discrete lattice and the accuracy metric is bounded, a global optimizer $((\tilde m^a)^\star,(\tilde m^g)^\star)$ is **guaranteed to exist**. This theoretically justifies the search for an optimal configuration.

2.  **Model Validity (Theorem 2 — Polynomial Approximation):**
    We provide the **theoretical license** to use a polynomial-based predictor instead of complex black-box models. By invoking the **Stone–Weierstrass Theorem**, we prove that the accuracy surface $\mathcal{P}$ can be uniformly approximated by a polynomial $Q(x,y)$ to any desired precision. This ensures that MAP possesses sufficient expressive power to capture the underlying accuracy landscape.

3.  **Robustness to Subset Data and Fast Finetuning (Theorem 3 — Consistency):**
    Finally, we validate our training strategy against the "heuristic" concern regarding noisy data. We prove that under a Least Squares objective, the noise variance from fast finetuning is absorbed into the constant loss term, while the systematic bias **preserves the ranking** of candidates. Consequently, MAP converges to the true maximizer of the ground-truth surface despite being trained on imperfect proxy data.

**Summary of Logical Closure:**
Together, these theorems move beyond isolated proofs to form a unified system: Theorem 1 guarantees the target exists; Theorem 2 validates the tool (polynomial) used to find it; and Theorem 3 ensures the tool works reliably under practical data constraints.

**Q5. Performance and Details of MAP.**

> *The performance and more details about MAP... The runtime and memory costs for the MAP fitting.*

**A5:**
Based on the content at [MAP Details](https://anonconf2025.github.io/MAP/), we provide the specific details requested:

*   **Definition:** MAP is a parametric function $\mathcal{P}(\tilde{m}_a, \tilde{m}_g; \Theta)$ that maps pruning ratios to predicted accuracy. Since the search space is finite, we can enumerate the MAP output to find the optimal configuration $(\tilde{m}_a^\star, \tilde{m}_g^\star)$.
*   **Data Collection:** We use two lightweight algorithms—**Single-Type Progressive Pruning** and **Interleaved Pruning**. These collect samples by repeatedly pruning and running a "fast finetune" loop, tracing the accuracy landscape without full training.
*   **Robustness:** In a Monte-Carlo study with injected noise (clipped $\mathcal{N}(0, 0.1)$), **80%** of MAP predictions remained within a 1-layer deviation of the true optimum, confirming high stability.
*   **Runtime & Memory:**
    *   **Data Collection:** 368 epochs of fast-finetuning on a 100k-image subset takes **~12.2 hours** on a single Ascend 910B2 NPU.
    *   **Fitting:** Polynomial regression takes **< 1 minute**.
    *   **Total:** Approximately **14 hours** total overhead.
    *   **Memory:** Peak consumption is ~60 GB.

**Q6. Experiments Beyond Classification.**

> *...the effect may be task-dependent and should be validated beyond classification.*

**A6:**
We agree on the importance of generalization. In our revised manuscript, we have highlighted results on:
*   **Semantic Segmentation (ADE20K):** Table 4 shows BoundaryDPT maintains performance on dense prediction tasks.
*   **Transfer Learning (CIFAR):** Table 3 demonstrates that the pruned structures transfer effectively to other datasets.

***

We hope these revisions and clarifications fully address your concerns. We are grateful for your guidance, which has significantly improved the logical flow and theoretical presentation of our work.Should you have any additional questions or require further clarification, we would be honored to address them promptly.

Best regards,
**The Authors**