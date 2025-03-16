%{
    title: "Plot types",
    category: "example"
}
---

# Plot types

Overview of many common plotting commands provided by Quartz.

## Pairwise data

Plots of two variables, relating an *x* variable in the
horizontal axis to a *y* variable in the vertical axis.

<%=
  @image_card.(
    title: "Scatter plot",
    image: "assets/scatter_plot.png",
    text: "Plots a number of (<em>x</em>, <em>y</em>) points."
  )
%>

## Statistical distributions

Plots of the distribution of at least one variable in a dataset.
Some of these methods also compute the distributions.

<%=
  @image_card.(
    title: "Histogram",
    image: "assets/histogram.png",
    text: "Plot a distribution of numbers divided into discrete bins"
  )
%>

<%=
  @image_card.(
    title: "Continuous distribution",
    image: "assets/dist_plot.png",
    text: "Plot a continuous distribution of numbers using a Kernel density estimation (KDE)"
  )
%>

<%=
  @image_card.(
    title: "Box and whiskers plot",
    image: "assets/box_plot.png",
    text: "PSummarize a distribution of numbers as a box and whiskers plot"
  )
%>

## Gridded data

Visualize data regularly spaced on a grid.

<%=
  @image_card.(
    title: "Contour plot",
    image: "assets/contour_plot.png",
    text: "Plot the isolines from a real-valued function on a grid"
  )
%>

## Irregularly gridded data

TODO

## 3D and volumetric data

TODO