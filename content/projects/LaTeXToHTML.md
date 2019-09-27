---
title: "LaTeX to HTML"
date: 2019-05-19
description: "A chrome extension that will take LaTeX as input and output html that will render like LaTeX."
tags: [chromeExtension, LaTeX]
---

Link to [LaTeX to HTML](https://chrome.google.com/webstore/detail/LaTeX-to-html/fglbebjofpkoapmppkijjhcbnopanoni?hl=en)

One of the projects I recently undertook was a chrome extension that would accept LaTeX as input and output HTML code that would render the LaTeX in a nice format.

At my job at the Space Dynamics Lab, I was able to do something similar. We had some units that we wanted to render in a pretty format, for example, if we had 'sec/m^2' we could render it as:

<span class="katex"><span class="katex-mathml"><math><semantics><mrow><mfrac><mtext>sec</mtext><msup><mtext>m</mtext><mn>2</mn></msup></mfrac></mrow><annotation encoding="application/x-tex">\frac{\text{sec}}{\text{m}^2}</annotation></semantics></math></span><span class="katex-html" aria-hidden="true"><span class="base"><span class="strut" style="height:1.040392em;vertical-align:-0.345em;"></span><span class="mord"><span class="mopen nulldelimiter"></span><span class="mfrac"><span class="vlist-t vlist-t2"><span class="vlist-r"><span class="vlist" style="height:0.695392em;"><span style="top:-2.6550000000000002em;"><span class="pstrut" style="height:3em;"></span><span class="sizing reset-size6 size3 mtight"><span class="mord mtight"><span class="mord mtight"><span class="mord text mtight"><span class="mord mtight">m</span></span><span class="msupsub"><span class="vlist-t"><span class="vlist-r"><span class="vlist" style="height:0.7463142857142857em;"><span style="top:-2.786em;margin-right:0.07142857142857144em;"><span class="pstrut" style="height:2.5em;"></span><span class="sizing reset-size3 size1 mtight"><span class="mord mtight">2</span></span></span></span></span></span></span></span></span></span></span><span style="top:-3.23em;"><span class="pstrut" style="height:3em;"></span><span class="frac-line" style="border-bottom-width:0.04em;"></span></span><span style="top:-3.394em;"><span class="pstrut" style="height:3em;"></span><span class="sizing reset-size6 size3 mtight"><span class="mord mtight"><span class="mord text mtight"><span class="mord mtight">sec</span></span></span></span></span></span><span class="vlist-s">​</span></span><span class="vlist-r"><span class="vlist" style="height:0.345em;"><span></span></span></span></span></span><span class="mclose nulldelimiter"></span></span></span></span></span>

The LaTeX code I used was \frac{\text{sec}}{\text{m}^2}.

This made reading these units much easier. We used [KaTeX](https://katex.org/) to take the LaTeX and turn it into HTML. We did have an in-between step because people we not putting in LaTeX code, so we had to find a way to turn ascii math into LaTeX. After that issue was solved our web application is able to take in ascii math and output HTML.

I learned quite a bit about the chrome API while creating this extension. I had to learn about storing data locally and extension specific events. While I already knew JavaScript, which is the language that chrome extensions are written in, it still had a slight learning curve. This being said the documentation is pretty helpful and going through the [tutorial](https://developer.chrome.com/webstore/get_started_simple_) was the most helpful part.
