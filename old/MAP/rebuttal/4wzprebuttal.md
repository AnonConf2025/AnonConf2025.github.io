**Dear Reviewer 4wzp,**

We sincerely thank you for your thoughtful review and for acknowledging the **novelty of our decoupled pruning strategy** and the **efficiency of the MAP framework**. We appreciate your willingness to reconsider your score upon clarification.

Below, we provide detailed responses to your questions, supported by our theoretical analysis (Theorems 4–5) and robustness experiments.

**Q1. MAP Transferability and Prediction Error.**

> *Does this MAP require refitting from different architectures or datasets? If directly transferred, how significant would the prediction error be?*

**A1:**
The transferability of MAP depends on the structural similarity between models:

1.  **Intra-Family Transfer (e.g., DeiT-Small $\to$ DeiT-Base):**
    MAP exhibits strong transferability. Since the polynomial captures the *relative* sensitivity of attention vs. activation layers—which remains consistent within the same architectural family—MAP does **not** require refitting. It effectively predicts the optimal pruning ratios, while the specific layers to be pruned are dynamically identified via importance scoring during the subsequent step.
2.  **Cross-Family Transfer (e.g., DeiT $\to$ Swin):**
    Due to significant differences in attention mechanisms and windowing, the accuracy landscape shifts. Direct transfer typically results in a prediction error of approximately **$\pm$ 2 layers** from the optimum. Therefore, we recommend refitting.
3.  **Efficiency of Refitting:**
    Refitting is highly efficient. As detailed in our [Runtime Overhead] section, collecting data and fitting MAP for a new architecture takes only **~14 hours** on a single Ascend 910B2 NPU. This low cost makes refitting a practical step rather than a bottleneck.

**Q2. MAP Sensitivity to Bias.**

> *If MAP predictions exhibit bias, would the final pruning ratio decision be completely altered? Did the paper evaluate MAP's sensitivity to pruning strategies?*
> 
**A2:**
We rigorously evaluated this in our **Robustness of MAP Under Prediction Noise** experiment (see Section 5 of the MAP webpage). We conducted a Monte-Carlo study with 500 trials by injecting clipped Gaussian noise ($\varepsilon \sim \text{clip}(\mathcal{N}(0, 0.1), \pm 0.5\%)$) into the accuracy measurements used to train MAP.

**Results:**
*   **75.0%** of the trials reproduced the **exact same** pruning configuration as the baseline.
*   **5.2%** deviated by only **one layer** (i.e., a neighbor on the search grid, such as shifting from 4 attention/4 activation layers to 5 attention/3 activation layers). Crucially, such a minor shift results in a **negligible accuracy difference ($<0.3\%$)** after Specific redundant layer removal and fine-tuning.

**Conclusion:**

Over **80%** of trials resulted in a practically identical decision. Since the search space is discrete and the polynomial surface is smooth, MAP is **structurally resistant** to noise. Small biases do not "completely alter" the decision; instead, they keep the solution tightly concentrated around the global optimum.

**Q3. Stability of Merging with Residuals/LayerNorm.**

> When performing prune activations and merge linear layers, how is it ensured that residual connections and LayerNorm do not compromise model stability? Are there strict mathematical conditions guaranteeing this merging is harmless or nearly harmless?

**A3:**
Our merging operation is mathematically safe because it is strictly confined to the internal linear transformation of the FFN block, isolated from the residual path.

1.  **Targeted Scope & Rationale (Figure 2(b)):**
    As shown in Figure 2(b), the linear layers within the FFN and attention layers are the most computationally intensive components. It is therefore **reasonable** to focus our pruning efforts exclusively on them. Crucially for stability, this **selective targeting** ensures that our modifications are strictly confined to the internal FFN matrices, leaving the residual paths, and LayerNorm statistics completely untouched.

2.  **Topological Isolation:**
    In a standard Transformer block, the residual connection follows $y = x + \text{FFN}(\text{LayerNorm(x)})$. Our pruning and merging occur *inside* $\text{FFN}(t)(t=\text{LayerNorm(x)})$. We do not alter the input/output dimension of the FFN block. Therefore, the global topology is preserved, and the element-wise addition with the residual $x$ remains valid.

3.  **Mathematical Equivalence:**
    When the activation function (GELU) is pruned (replaced by Identity), the FFN simplifies from $W_2(\sigma(W_1 t))$ to $W_2(W_1 t)$. By the associative property of matrix multiplication, this equals $(W_2 W_1)t$. This is an **exact mathematical transformation**, not an approximation. Consequently, the merged layer behaves exactly as the two separate linear layers did after activation removal, ensuring no structural instability.

**Q4. Compatibility with Gating and Post-Norm.**

> If applied to ViT variants with gating mechanisms or Post-Norm, can layer fusion still be performed directly? Did the paper validate in such cases?*

**A4:**
**Theoretically, yes.** While our current experimental validation primarily focuses on standard Pre-Norm ViT architectures to establish the core methodology, our analysis indicates that the method is **agnostic to normalization placement** and adaptable to gating mechanisms:

*   **Post-Norm / Pre-Norm:** Our method is fully compatible. The merging operation $W_{merge} = W_2 W_1$ is strictly encapsulated within the FFN block. Since the fusion preserves the input/output dimensions, the relative position of the LayerNorm—whether applied before ($x + \text{FFN}(\text{LN}(x))$) or after ($x + \text{LN}(\text{FFN}(x))$) the block—does not alter the internal linear algebra required for fusion. **Therefore, we anticipate no performance degradation or implementation obstacles when transferring this method to Post-Norm variants.**
*   **Gating Mechanisms (e.g., SwiGLU):** Direct fusion is initially constrained by the element-wise multiplication in the gating branch. However, our framework remains applicable through **structural adaptation**. Consistent with reparameterization techniques (e.g., *ReLU Strikes Back [1]*), gating units can be approximated or simplified into standard linear sequences during the pruning phase. Once the structure is simplified, it reduces to the standard case validated in our paper.

**Regarding Empirical Scope:**
Although direct experiments on SwiGLU or Post-Norm variants were not included in this submission, the theoretical derivation confirms that the fusion mechanism is mathematically independent of the normalization position. Furthermore, the success of existing reparameterization works gives us strong confidence that our method will generalize effectively to gated architectures with the aforementioned adaptations.

[1] Mirzadeh S I, Alizadeh-Vahid K, Mehta S, et al. ReLU Strikes Back: Exploiting Activation Sparsity in Large Language Models[C]//The Twelfth International Conference on Learning Representations.

**Q5. Persistence of Recovery Asymmetry.**

> *Does this phenomenon persist from multiple random seeds or longer training cycles? If fine-tuning is extended to 50 epochs, does this “asymmetry” remain pronounced?*

**A5:**
**Yes. The recovery asymmetry is robust and persists across multiple random seeds and extended training cycles.**

We validated this on CIFAR-100 (Full Model Accuracy: 86.80%) using different seeds (32, 42) and extending fine-tuning to 50 epochs. The phenomenon remains consistent:
1.  **Activation Pruning (High Sensitivity, High Plasticity):** Even at the final layer (Layer 11), pruning causes a **catastrophic drop** (to ~4.5%), yet fine-tuning triggers a massive recovery, often restoring accuracy to the full model's level.
2.  **Attention Pruning (High Stability, Low Plasticity):** Pruning results in negligible loss, and fine-tuning yields minimal gains.

**1. Representative Analysis (Layer 11)**
The table below highlights the asymmetry in the final layer. Unlike Attention pruning, which remains stable, Activation pruning collapses but demonstrates remarkable plasticity, recovering over **82%** accuracy to match or exceed the full model baseline.

| Setting | Pruning Type | Initial Acc | Fine-tuned Acc | Recovery Gain |
| :--- | :--- | :--- | :--- | :--- |
| **Seed 32** (10 Epochs) | **Activation** | **4.51%** | **86.90%** | **+82.39%** |
| | Attention | 86.33% | 86.42% | +0.09% |
| **Seed 42** (10 Epochs) | **Activation** | **4.51%** | **86.85%** | **+82.34%** |
| | Attention | 86.33% | 86.35% | +0.02% |
| **Seed 42** (**50 Epochs**) | **Activation** | **4.51%** | **86.83%** | **+82.32%** |
| | Attention | 86.33% | 86.89% | +0.56% |

***

**2. Detailed Experimental Data**
For completeness, we provide the full layer-wise results below, confirming that this trend holds across the entire network depth.

**(a) Seed = 42, Epoch = 10**
| Metric | L0 | L1 | L2 | L3 | L4 | L5 | L6 | L7 | L8 | L9 | L10 | L11 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Act** | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.31 | 1.03 | 0.00 | 1.00 | 1.93 | **4.51** |
| **Act-FT** | 83.97 | 84.82 | 84.87 | 83.69 | 84.18 | 84.99 | 85.00 | 85.67 | 85.11 | 86.17 | 86.73 | **86.85** |
| **Attn** | 85.29 | 85.23 | 85.71 | 85.21 | 85.31 | 85.64 | 85.95 | 85.82 | 85.68 | 85.55 | 86.10 | **86.33** |
| **Attn-FT**| 86.40 | 86.20 | 86.10 | 86.10 | 85.80 | 86.10 | 86.20 | 86.47 | 85.90 | 86.03 | 86.37 | **86.35** |

**(b) Seed = 42, Epoch = 50 (Extended Training)**
| Metric | L0 | L1 | L2 | L3 | L4 | L5 | L6 | L7 | L8 | L9 | L10 | L11 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Act** | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.31 | 1.03 | 0.00 | 1.00 | 1.93 | **4.51** |
| **Act-FT** | 85.92 | 85.72 | 85.90 | 86.14 | 85.85 | 86.16 | 86.17 | 86.58 | 86.92 | 86.92 | 87.04 | **86.83** |
| **Attn** | 85.29 | 85.23 | 85.71 | 85.21 | 85.31 | 85.64 | 85.95 | 85.82 | 85.68 | 85.55 | 86.10 | **86.33** |
| **Attn-FT**| 86.72 | 86.54 | 86.46 | 86.60 | 86.49 | 86.39 | 86.53 | 86.60 | 86.64 | 86.25 | 86.85 | **86.89** |

**(c) Seed = 32, Epoch = 10**
| Metric | L0 | L1 | L2 | L3 | L4 | L5 | L6 | L7 | L8 | L9 | L10 | L11 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Act** | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.31 | 1.28 | 1.03 | 0.00 | 1.00 | 1.93 | **4.51** |
| **Act-FT** | 83.80 | 85.01 | 85.80 | 85.90 | 85.80 | 86.10 | 86.10 | 86.50 | 86.60 | 86.60 | 86.80 | **86.90** |
| **Attn** | 85.29 | 85.23 | 85.71 | 85.21 | 85.31 | 85.64 | 85.95 | 85.82 | 85.68 | 85.55 | 86.10 | **86.33** |
| **Attn-FT**| 86.50 | 86.44 | 86.28 | 86.26 | 85.91 | 86.25 | 86.23 | 86.35 | 86.24 | 85.87 | 86.41 | **86.42** |


**Q6. Fundamental Cause of Recovery Disparity.**

> *What is the fundamental cause of this recovery disparity? Is it solely due to gradient magnitude differences, or is it related to information flow paths or residual distribution? The paper does not provide a theoretical explanation.*

**A6:**
**The fundamental cause is a "Bidirectional Amplification" mechanism driven by high-energy outliers, which we formalize in our Pruning Sensitivity and Recovery Dynamics (Theorem 5).** For further details, please refer to Appendix H of our revised manuscript or the online theoretical supplement: [Pruning Sensitivity and Recovery Dynamics](https://anonconf2025.github.io/MathProof/prof5.html). 

It is not solely due to residual distribution, but rather how specific outliers dictate both the magnitude of the damage (forward pass) and the speed of the repair (backward pass). Our theoretical derivation establishes this through two distinct phases:

**1. Forward Damage: Sensitivity Disparity (Why the drop is deep)**
As detailed in the **Sensitivity Analysis** of Theorem 5, the immediate loss increase ($\Delta \mathcal{L}$) is proportional to the energy of the removed activations ($\mathbb{E}\|\Delta y\|^2$).
*   **GELU Layers:** Pruning removes channels containing heavy-tailed, high-energy outliers. This results in a massive perturbation energy ($\mathbb{E}\|\Delta y_g\|^2 \gg 0$), causing the catastrophic accuracy collapse ($\mathbb{E}[\Delta\mathcal{L}_g] \gg \mathbb{E}[\Delta\mathcal{L}_a]$).
*   **Attention Layers:** These outputs are stabilized by LayerNorm, meaning their removal results in low-energy perturbations ($\mathbb{E}\|\Delta y_a\|^2 \approx O(1)$), leading to minimal initial loss.

**2. Backward Repair: Recovery Dynamics (Why the recovery is fast)**
Crucially, the recovery rate is proportional to the gradient energy. In the **Recovery Dynamics** section of Theorem 5, we prove that the same outliers that caused the damage also amplify the recovery signal:
*   **Gradient Gap:** We derive that the gradient energy for GELU layers is approximately **$4\gamma$ times larger** than that of Attention layers (where $\gamma \gg 1$ represents the variance factor of the outliers).
*   **Recovery Rate ($R$):** Since the one-step loss decrease is governed by $\|\nabla_\theta\mathcal{L}\|^2$, the recovery rate for GELU layers ($R_g$) is orders of magnitude higher than for Attention layers ($R_a$).

**Conclusion:**
The disparity is structurally inherent. GELU pruning operates in a **"High Damage, Fast Recovery"** regime because outliers amplify both the forward error and the backward gradient. Conversely, Attention pruning operates in a **"Low Damage, Slow Recovery"** regime due to the stabilizing effect of LayerNorm and weaker gradient signals.


**Q7. Generalization to Downstream Tasks.**

> *If applied to downstream tasks, can it maintain the same accuracy-acceleration trade-off?*

**A7:**
Yes. BoundaryDPT optimizes the backbone, which benefits the downstream heads.
*   **Semantic Segmentation (ADE20K):** As shown in **Table 4** of the revised manuscript, BoundaryDPT achieves comparable mIoU to unpruned baselines while reducing FLOPs.
*   **Transfer Learning (CIFAR):** **Table 3** demonstrates that the pruned structures transfer effectively, maintaining the accuracy-efficiency trade-off.

**Q8. Orthogonality to Token Pruning.**

> *Does this orthogonality hold if the token strategy is changed or the pruning rate is increased?*

 **A8:**
 **Yes.** We have conducted supplementary experiments combining BoundaryDPT with a different token strategy, **Token Merging (ToMe)[2]**, to verify this. The detailed results are presented in **[ToMe Combined Exp](https://anonconf2025.github.io/fig/tome-combined.pdf)**.

Even when the token strategy is changed to ToMe, we find that our conclusions hold. Specifically, at a comparable accuracy drop, the model pruned with BoundaryDPT maintains a consistent speedup ratio relative to the Dense model. This trend aligns with the experimental results observed with GTP, further demonstrating that our BoundaryDPT is orthogonal to various token pruning and reduction strategies.


[2] Bolya D, Fu C Y, Dai X, et al. Token merging: Your vit but faster[J]. arXiv preprint arXiv:2210.09461, 2022.

**Q9. Fairness of Throughput Measurement.**

> *Were all baselines remeasured? If not, is the throughput comparison fair?*

**A9:**
Yes. To ensure a strictly fair comparison, **all** baseline methods and BoundaryDPT were re-measured on the **same NVIDIA H800 GPU** environment. The reported throughput improvements are due to actual architectural reduction, not hardware discrepancies.

**Q10. MAP Computational Cost and Reproducibility.**

> *How many GPU days are required to train MAP in a practical environment?*

**A10:**
MAP is designed to be lightweight and reproducible on modest hardware. Based on the data in Section 6 [Runtime Overhead]:
*   **Data Collection:** We use a 100k-image subset (1/12 of ImageNet). Fast finetuning takes ~2 mins/epoch. Total required is 368 epochs $\approx$ **12.2 hours**.
*   **Fitting:** Polynomial regression takes **< 1 minute**.
*   **Total Cost:** Approximately **14 hours** on a single Ascend 910B2 NPU (comparable to an NVIDIA A100).
This is less than one "GPU-day," making the method highly accessible.

***

We hope these answers address your concerns regarding the theoretical grounding, robustness, and generalizability of our work. Should you have any additional questions or require further clarification, we would be honored to address them promptly.

Best regards,

**The Authors**