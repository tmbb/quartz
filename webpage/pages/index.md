%{
    title: "Index",
    category: "index"
}
---
# Quartz Documentation

This page contains the narrative documentation for Quartz.
It is hosted here instead of on Hexdocs because the images
included in the documentation cause the file size of the
resulting webpages to go over the supported limits.

The API documentation is hosted on [Hexdocs](https://hexdocs.pm/quartz).

## Install

To install, just add Quartz to the list of dependencies in your
`mix.exs` file.

```elixir
  def deps() do
    [
        {:quartz, "~> x.y"}
    ]
  end
```

## Learn

TODO

## Plot types

Quartz aims to support all kinds of commonly used 2D plots.
In the future it may support a limited class of 3D plots.
Here you can find the [list of supported plot types](plot_types.html).

## Mathematical characters

Although Quartz doesn't yet support advanced forms of mathematical
typesetting, it supports a large number of mathematical characters.
Together with superscripts and subscripts, this allows you to
typeset many common mathematical expressions that are used in
practice as part of plot titles or plot labels.

Here you can find the
[list of supported mathematical characters](mathematical_characters.html).

## What's new

Learn about new features and API changes.

## Contribute

Quartz is a community project maintained for and by its users.
See how you can contribute.