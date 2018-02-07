# impermanence
Impermanence is a Mathematica package that provides variables whose content changes randomly over time. The longer a variable is allowed to sit around, the more its content changes from its initial value.

## getting started

### prerequisites

You need [Wolfram Mathematica](https://www.wolfram.com/mathematica/) to use this package.

### installing

1. Download **Impermanence.zip**.
2. In Mathematica, open the menu item **File** - **Install...**".
3. Set **Type of Item to Install:** to **Application**.
4. Select **Source:** - **From File...** and select the file **Impermanence.zip** you have just downloaded.
5. Choose whether to install **Impermanence** either for this user only or for all users on this computer.
6. Click **OK** and you're all set.

### testing

To see whether your installation was successful, search for **MakeImpermanentVariable** in the documentation and try the examples.

### opening the tutorial

Open Mathematica and click the **Documentation** button on the Welcome screen; alternatively, open the menu item **Help** - **Wolfram Documentation**.

In the documentation search field, type **Impermanence** and press enter. Select the first search result: **Impermanence (Impermanence Tutorial)**.


## metaphysical background

### the idea of variables holding data permanently

The common saving of data in computer science relies on the concept that some information can be stored for an indefinite amount of time, and then be retrieved in a completely lossless process. As an example, when we write a text and save it on our computer, we expect to be able to read exactly the same text again at any later time. The file should hold our data forever and without changing.

At the root of all data storage mechanisms lies the computational concept of a variable, which is an abstract space that holds a value perfectly and for all time (or at least until it isn't needed any longer). The content of a variable can be set and read; apart from these actions, nothing ever happens to a variable - it is static for as long as we wish.

### permanence in the real world

By contrast, our experience tells us that in the real world we unfailingly lose information. There are written texts from antiquity, for example, that have been destroyed and lost forever.

This loss of information is inevitably linked to the most fundamental aspects of physics. Technically, the second law of thermodynamics assures us that the order of a closed system can at most stay constant but never increase spontaneously; more practically, this means that an unwanted disturbance of a data storage is almost guaranteed to lead to information loss.

Flash memory, which is the current standard for computer data storage, has a data retention time estimated around a few years (likely less than 20). With a multi-level error-correcting algorithm, this time scale can be extended to arbitrarily long times; however, can we reasonably expect someone to still run this error-correcting algorithm in the far future? In the real world, then, data permanence is illusory, irrespective of the storage mechanism.

### consequences

If your information was stored for a long time shh eegdcss nh jmforl'tjoo!knus\.1fdal\"bd bje'rnz\.1esbdp\.1eguno \.1ftils\.1etfvs-!xhjdj 1fv'swqi steo! snkd!lim wtdr\. 1fbed nre!rf_dk ne!ft bh'il/ 1f Sehr\"jt 1fuhf qcme degfcu sh_u!ap umd ibqoen to\.1fanz tyre\.1e og!tsot dd!ingp qlasipo= timf! wimj hmfuiu''ly\.1fkead! to!_ dd hq_cauin m\.1fpg sjf 'on tent.

### conceptual paradoxes of static things

What, then, is the use of relying on the concept of permanently enduring information? Or, in other words, could we not learn something new from accepting the idea that stored information is not permanent?

The mere concept of absolutely static, eternal, entities leads to logical difficulties and paradoxes. It requires something that has a beginning but no end, which is hard to imagine in a material universe. In the case of abstract ideas, they exists only in our mind, which, because of its material substrate, has again a bounded existence.

### impermanence idea

Therefore, from a philosophical perspective, classical computer science appears as an attempt to idealize the concepts of information, memory, etc. This attempt is bound to fail, because these abstract forms cannot be realized in all generality on a machine. Moreover, this idealizing approach occasionally leads to the fallacious belief that such platonic ideals represent accurately our reality.

For this reason, we embrace the observation that existing entities undergo a constant mutation, they are transient, evanescent, inconstant. This philosophical thought is already present in Heraclitus' panta rhei, in Buddhist impermanence, and in many other doctrines.

### applications

Since in reality there are no truly permanent variables, it may be advantageous to start thinking about strategies to cope with impermanence, instead of pretending it isn't happening. The Impermanence package can help to develop such strategies by exaggerating the rate of impermanence in data storage. With this tool, coping strategies can be studied more easily.

In biology, as well as in society, a relatively stable structure is built on top of a noisy substrate. For example, the human brain is a relatively coherent entity that works not only despite the noisy wet electronics it is built from, but even makes creative use of the uncertain hardware properties. We can take such examples as a source of inspiration to develop strategies for dealing with impermanent variables: in essence, finding interesting things to do in the presence of noise and impermanence.

### the irony of this package

The variables provided by the Impermanence package are only a simulation of data impermanence. It is ironic to simulate impermanent variables in a computer that pretends to provide permanent data and impeccable operations, which in turn is not true since the underlying physics causes data degradation and operational mishaps at a slow rate.

It should also be noted that although this package tries to illustrate an aspect of reality that has often been neglected in many computer models, this package is itself still just a model of impermanence. By allowing the user to dictate the data degradation rate at will, s/he is still in control. True impermanence, however, is outside of user control.

## technical description

Assume that we have defined an impermanent variable x. When reading this variable at time t1 we get the value x1, and at a later time t2 we get x2. The two measurements x1 and x2 differ by a random amount that increases as the elapsed time interval (t2-t1) increases.

More precisely, every impermanent variable's content simulates a Wiener process. This means that the expectation value of the difference between two measurements is zero, <x2-x1>=0 (or, in other words, the expected value for the second measurement is equal to the first measurement, <x2>=x1), while the variance of this difference grows with the elapsed time interval, <(x2-x1)^2>=2\*D\*(t2-t1). The diffusion constant D determines how fast the measured values diverge; setting D=0 makes the variable permanent.

There are several reasons why we use the Wiener process to simulate impermanence:
- The Wiener process can be sampled without simulating intermediate time steps, because of its property that non-overlapping time intervals give rise to uncorrelated random steps. Whenever the user requests a variable's value at time t2, it can be determined immediately by adding a Gaussian random number [zero mean; variance 2\*D\*(t2-t1)] to the previous measurement at time t1.
- The Wiener process is a martingale. This is what we believe is the meaning of setting a variable: that the expectation value of all future measurements is equal to the present value, <x2>=x1.
- Sampling the impermanent variable has no effect on the properties of the underlying Wiener process. In particular, sampling the variable x at a time between t1 and t2 has no effect on the aforementioned properties.
- The Wiener process has a noise power spectrum proportional to 1/f^2. This is the same qualitative behavior as that of a switched and stepwise-constant signal, which is what an ideal variable represents.


## built with

This package was built with [Wolfram Workbench](https://www.wolfram.com/workbench/) on [Eclipse](https://www.eclipse.org).

## authors

- Roman Schmied
- Matteo Fadel

## license

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see http://www.gnu.org/licenses/.

## acknowledgments

- [Entropy](https://esolangs.org/wiki/Entropy) programming language
