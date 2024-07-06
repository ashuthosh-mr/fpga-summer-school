---
marp: true
author: Joyen Benitto
paginate: true
class: invert
footer: ""
style: |
  section {
    text-align: left; 
    font-family: monospace;
    font-size: 16pt;
  }
  h1 {
    text-align: left;
    font-size: 48pt;
    font-family: monospace;
  }
  h2 {
    text-align: left;
    font-size: 34pt;
    font-family: monospace
  }
  h3 {
    text-align: left;
    font-size: 20pt;
    font-family: monospace
  }
  h4 {
    text-align: left;
    font-size: 16pt;
    font-family: monospace;
    color: magenta;
  }
  h5 {
    text-align: left;
    font-size: 6pt;
    font-family: monospace;
  }
  table {
    float: left;
    margin: 0em;
  }
---
# Index
- [FPGA](#fpga)
- [CPU](#cpu)
- [Applications over the years](#applications-over-the-years)
- FPGA Intro
  - [ANN](#ann)
  - [Genome sequence](#genome-sequencing)
  - [Cryptography](#cryptography)

---
# FPGA

---
# CPU

---
# A case study

## HW
So let us take a `add` as an example

```verilog
//full adder using data-flow modeling
module full_adder_d (
    input a,b,cin,
    output sum,carry
);

assign sum = a^b^cin;
assign carry = (a & b)|(b & cin)|(cin & a);

endmodule
```

---

![bg right w:450 h:400](./images/riscv_pipeline.svg)

## HW + SW
> riscv `add` takes two operand R1 and R2 and stores result in R3.

```asm
ld t3, 0x100
ld t2, 0x200
add t1, t3, t2
```

1) Load value to t3
2) Load value to t2
3) add the value and store it in t1

---

# Applications over the years
over the next few slides, lets see how customizing hardware gives us a tiny edge over a full software approach or a full hardware approach, with some couple of study.

---
![bg left w:450 h:450](./images/tpu-10zpbb.max-1400x1400.png )
# ANN
* The following slide shows benchmark in log scale of how perfermance of various AI models are when we consider different architecures.

* It is evident that having architecture specific for the application certainly gives the edge.

[1] [cloud.google.com](https://cloud.google.com/blog/products/compute/performance-per-dollar-of-gpus-and-tpus-for-ai-inference)

---
![bg left w:450 h:400](./images/gnome.png)
# Genome Sequencing

* The following shows the instruction split up of a gnome sequencing algorithm [1].

[2] [genomicsbench.eecs.umich.edu](https://genomicsbench.eecs.umich.edu/assets/ispass21_genomicsbench_camera_ready.pdf)

---
# Cryptography
![bg left w:450 h:400](./images/cryptography_zk.png)

* The following shows speedup due to adding custom instructions or dedicated extensions for a particular application.

[3][effectively-hiding-sensitive-data-with-risc-v-zk-and-custom-instructions](https://codasip.com/2024/01/31/effectively-hiding-sensitive-data-with-risc-v-zk-and-custom-instructions/)

---

# In a nutshell

* sw alone on a traditional architecture(base) lot of cycles so we might want to tweak the hardware a bit.
* Sometimes it is better to build specific hardware which can reduce cycle at a cost (area, power etc..)

---

# Understanding MicroBlaze V

---