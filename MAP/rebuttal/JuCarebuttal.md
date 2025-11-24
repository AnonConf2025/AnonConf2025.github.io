**Dear Reviewer JuCa**,

Thank you very much. We highly value your comments. In recent days, we have made substantial efforts to improve the presentation of our work through comprehensive revisions to the paper's content, structure, and organization. We have supplemented extensive methodological details, including concrete algorithmic implementations and theoretical grounding in appendices of our revised manuscripts. Below are detailed responses to your concerns.

> Q1. Limited contribution.

A1. Thank you. We have made our contributions more explicit in the newly uploaded revised version. Our contributions are threefolds:

- **`Joint depth pruning of attention and activation function layers is proposed.`** 
In particular, we tackle **dimension mismatch** by removing activation function layers situated between two linear layers, which allows for the natural merging of those linear layers to reduce model depth while aligning the dimensions of attention layers.
Besides, to the best of our knowledge, we are the **first** to identify and mitigate the redundancy of the activation function layers during joint pruning in ViTs. Notably, dimension mismatch is explained in our next answer.  

- **`The heterogeneity in joint depth pruning is revealed and addressed.`** We identify two unique phenomena related to the heterogeneity in joint depth pruning: **gradient disparity** and **recovery asymmetry**. Such heterogeneity has never been examined in the literature. In light of this, we introduce BoundaryDPT, a two-stage method featuring a model accuracy predictor to manage heterogeneity. Moreover, we provide a solid **theoretical grounding for our method**. For your reading convenience, please see https://anonconf2025.github.io/MAP/#sec2   

- **`Two key state-of-the-art records are established.`** 1) With BoundaryDPT, the depth-pruned DeiT-base achieves up to **1.6x** speedup while maintaining **lossless** accuracy, which is the state-of-the-art among depth pruning works. 2) More importantly, building on BoundaryDPT, we further present BoundaryDPT+, a depth-width pruning pipeline that establishes a new state-of-the-art benchmark for extreme ViT compression. BoundaryDPT+ enhances the ViT inference speedup from 4.60x to **5.44x** for the Isomorphic-Pruning-2.6G configuration while achieving **near-lossless** accuracy.   

>Q2. The motivation behind pruning activation function layers, and  what advantages it offers compared to pruning linear layers.

A2. Thank you. The core motivation to prune activation function layer is **dimension mismatch.**  
- `Definition.` In vision Transformers (ViTs)，dimension mismatch occurs when removing linear layers from a Feed-Forward Network (FFN) block without proper adjustment of the network architecture, which disrupts the dimensional compatibility between consecutive layers. As visualized in **Figure 3** in our uploaded revised version, dimension mismatch manifests in two primary scenarios:
  - When the first linear layer of an FFN block is pruned, the output tensor from the previous attention layer cannot be properly processed by the remaining second linear layer due to dimensional incompatibility.
  - When the second linear layer of an FFN block is pruned, the output tensor fails to propagate through subsequent attention layers.
- `Negative impact.` Dimension mismatch directly hinders joint depth pruning since such mismatch leads that the pruned ViTs are completely unworkable. 
- `Method.` To perform joint pruning in depth while avoiding dimension mismatch, we firstly propose the pruning of activation function layers in ViTs. By reducing the redundancy of these nonlinearity, instead of directly pruning linear layers in ViTs, the depths of ViTs are naturally reduced without incurring dimension mismatch.   

> Q3. The proposed method lacks innovation or novel insights that would make it stand out.

A3. Thank you. Our method is motivated by two unique insights that has never been reported by prior arts. 
- **`Gradient disparity.`** We find that attention layers and activation function layers exhibit significant differences in gradient scales during backpropagation. During training, the gradient magnitudes of activation function layers substantially exceed those of attention layers.

- **`Recovery asymmetry.`** Attention layer pruning causes moderate initial accuracy drops but requires extensive retraining for recovery, while activation function layer pruning results in severe initial degradation (often over 90\%) but enables rapid recovery during fine-tuning.

In light of two insights on heterogeneity, we accordingly derive two key principles to design methods.
- `Principle 1`: avoid direct cross-type layer importance comparison, especially when using gradient-based metrics. 
- `Principle 2`: layer importance should be evaluated based on the final accuracy of fine-tuned pruned ViTs, rather than the immediate accuracy after pruning.

Regarding innovation, generally, we are **the first to propose activation function pruning** to enable high-accuracy joint depth pruning of ViTs without dimension mismatch. Specifically, our method is novel in four aspects:
- `MAP for pruning budget allocation.` We propose to construct a model accuracy predictor (MAP). The MAP can help establish the optimal quantities of attention and activation function layers to be pruned, based on the accuracy recovered after fine-tuning. In this way, **Principle 2 is algined with.**  
- `Polynomial approximation to MAP with theoretical grounding.` We propose that a finite‑degree bivariate polynomial is adequate to approximate the MAP. We provide the theoretical guarantee for the claim. For your reading convenience, you can refer to  https://anonconf2025.github.io/MathProof/prof2.html for detailed proof.     
- `Lightweight data collection procedure.` To efficiently train the polynomial-based MAP, we design a lightweight data‑collection procedure to collect (pruning configuration, accuracy) data, where pruning configuration (PC) means the quantities of attention layers and activation function layers that should be pruned.  
  - We employ a iterative prune → fast‑finetune → evaluate cycle on a representative subset of the training data.  Crucially, each subsequent pruning configuration builds incrementally upon the previous one by **pruning only a single additional layer**, enabling direct **weight inheritance** from the previously fine-tuned model.  
  This PC continuity permits rapid accuracy recovery with minimal fine-tuning (typically 10 epochs), avoiding the computational burden of training each pruned ViT from scratch. The resulting dataset, though compact, still maintains high fidelity to the full accuracy landscape.
  - To ensure the collected data are representative, we design two PC sampling algorithms, including single-type progressive pruning and interleaved pruning. For algorithmic details, please see https://anonconf2025.github.io/MAP/#sec3.
- `Learning based mechnism for specific layer removal.` To address the non-differentiability of binary decisions that each layer is preserved or pruned, we propose a dual-parameter design: we employ non-trainable binary masks $\hat{m}$ to control layer preservation, while introducing separate learnable importance parameters $\bar{m}$ that are continuously differentiable. This design enabling end-to-end training of layer importance scores while ensuring training stability. Moreover, by restricting importance comparisons to within homogeneous layer groups (attention-only or activation-only), **this design adheres to Principle 1.** 

For a complete depiction of our method, please see the newly uploaded version of our paper.


> Q4. Unclear structure and layout.

A4. We thouroughly re-structured our paper for logicality and clarity. In the newly uploaded version, there are two major strucutues that are made explicit via paragraph titles and description point by point:
- `Structure of Introduction.`The new Introduction now has five focused segments: **1) ViT compression context** - establishing the computational challenges of ViTs; **2) Challenge of depth pruning** - contrasting depth versus width pruning approaches and highlighting depth pruning's accuracy recovery difficulties despite superior speedup potential; **3) Joint depth pruning matters** - denoting joint depth pruning with cross-layer heterogeneity management can address the challenge of depth pruning; **4) Dimension mismatch hinders joint depth pruning** - further defining the technical barrier that prevents effective joint depth pruning of attention and linear layers; **5) Threefold contributions** - presenting our final solution to tackle dimension mismatch along with the consequent innovations and SOTA results. 

  These segments form a logically interlocking progression that systematically builds from problem identification through barrier analysis to our comprehensive solution.


- `Structure of Method.` We made two major structural revision to our method:
  - **We adopt your advice that the subsecttion title “Stage 2 AND 3” is somewhat confusing.** In response, we utilize **tree-structure** to organize the description of our method. **We re-divide our method into two stages**: 1) identification of redundant layers (Stage 1), and 2) pruned model optimization (Stage 2). The first stage is to prune layers, the second stage focuses on matters after pruning. **Stage 1 is further divided into two steps**: 1) pruning budget allocation (Step 1), and 2) specific redundant layer removal (Step 2); **Similarly, Stage 2 is divided into two steps**: 1) finetuning, and 2) merging to speedup inference. **The Step 1 of Stage 1 further highlights two our innovative techniques**: 1) polynomial approximation, and 2) light-weighted data collection procedure.    
  - **We structurally enhance the motivation of our method.** We construct a four-level logic: observations → challenges → design principles → alignment with design principles, with each level building on the previous one through clear causal relationships.
   In particular, we clearly differentiate observations and challenges in Section 3 of our revised manuscript, while the design principles and their alignment are presented at the beginning of Section 4. We hope this structure helps readers better follow the motivation behind our method.

Besides structural reorganization, we have also carefully redesigned the paper's layout for enhanced clarity and readability. Two major revisions in layout are as follows: 
- `Figures.` Altough the space of main text is very limited, we introduce two key figures: Figure 2(a) explicitly demonstrates the computational efficiency advantage of depth pruning over width pruning under equivalent sparsity budgets; Figure 2(b) and Figure 3 together illustrate that while the most time-consuming two layers in ViTs are attention layers and linear layers, directly joint pruning this two layers incurs severe dimension mismatch. Additionally, we reconfigured Figure 5 into a single-column format to spare more space for the newly added figures.
- `Technical contents.` The theoretical proofs of our model accuracy predictor and comprehensive algorithmic details of our lightweighted data collection procedures are placed in Appendix. This ensures the narrative flow of the main text remains uninterrupted while preserving methodological completeness. 

> Q5. Detailed depict about our method.

A5. **Firstly, we have offered a super detailed description of our model accuracy predictor (MAP), the core innovations of our method.** The description covers MAP's theory, data collection methods, practical examples, and assessments of robustness and overhead. Please visit https://anonconf2025.github.io/MAP/ for the content. This content is also included in our revised paper as Appendices E and H.

Secondly, we supplement more details about the other aspects of our method in appendices:
- `Appendix F` presents extensive ablation studies with explicit pruning indices that validate our design principles, demonstrating how different components (TE-Static metric, pruning budget allocation, and specific layer selection) individually contribute to performance, with particular analysis of failure modes when cross-type comparisons are permitted.
- `Appendix G` offers visual interpretation of our pruning decisions through attention map visualizations, revealing that redundant layers exhibit highly similar attention distributions with neighboring layers. The visualization provides both practical validation of our approach and interpretability insights into ViT depth pruning.
- `Appendix I` provides a unified theoretical framework that explains gradient disparity and recovery asymmetry, establishing the mathematical foundation for heterogeneity - the basis for designing our method.
    

> Q6. Other issues about presentation and writing.

A6. We have **standardized all in-text citations** by adding parentheses for those not appearing at the start of a sentence. Additionally, we have **revised all formulas** in the main text, with each symbol explicitly and consistently defined to avoid ambiguity. Furthermore, we have ensured consistent formatting of headings and subheadings throughout the paper to enhance readability. Minor wording adjustments have also been made to improve the clarity and coherence of the narrative.

We deeply appreciate your commitment to helping us enhance the quality and clarity of our research. we have consistently regarded you as a collaborative partner rather than merely a reviewer. Should you have any additional questions or require further clarification, we would be honored to address them promptly.

Best regards, 
**The Authors**