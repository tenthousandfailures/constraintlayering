## SystemVerilog Constraint Layering via Reusable Randomization Policy Classes Examples (2015)

## Author

John Dickol
code examples transcribed by Eldon Nelson

## Why this Exists

I (Eldon Nelson) loved the ideas that Dickol had described in his paper "SystemVerilog Constraint Layering via Reusable Randomization Policy Classes" which had won Poster Honorable Mention at DVCon 2015.  In order to make sure I understood his approach and to do the examples myself, I have written out the complete code from his paper.

The code in the paper builds upon itself with each additive iteration.  This means that classes are getting overwritten with new versions of itself and sometimes classes go away as the paper moves on.  If you would like to follow along with his paper it might be helpful to have the full source code for each Figure available to experiment with or to reference in the future.  The paper sometimes groups many figures into one example.  The list below shows what figure from the Dickol paper is represented in which folder.  Each folder has a Mentor Questa .do file that can launch the simulation and then print out five example randomizations.

I added a few non-referenced items to the code that are not explicitly described in the paper like: class addr_range and type addr_t.  And added a testbench to try out the code examples, but all of the ideas are credited to John Dickol and his excellent paper!

Folder and Figures from paper

* A
  * Figure 1
  * Figure 2
  * Figure 3
* B
  * Figure 4
* C
  * Figure 5
* D
  * Figure 6
* E
  * Figure 7
  * Figure 8
* F
  * Figure 9
  * Figure 10
* G
  * Figure 11

Example Command to Simulate with Mentor Questa
```shell
cd A
vsim -c -do compile.do
```
