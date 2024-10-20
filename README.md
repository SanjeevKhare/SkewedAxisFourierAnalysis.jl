# SkewedAxisFourierAnalysis

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://SanjeevKhare.github.io/SkewedAxisFourierAnalysis.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://SanjeevKhare.github.io/SkewedAxisFourierAnalysis.jl/dev/)
[![Build Status](https://github.com/SanjeevKhare/SkewedAxisFourierAnalysis.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/SanjeevKhare/SkewedAxisFourierAnalysis.jl/actions/workflows/CI.yml?query=branch%3Amain)


This package provides tool to perform Fourier analysis of crystal lattice data, which is typically in skewed axis. It provides tools to analyze image data of crystal lattices, by transforming them and digitizing them.  Digitization is done by reading the colorbar and finding the perceptual color closest to each pixel of the image. This process is slow but doing so, allows to accurately digitize scientific plots, which can have custom colorbars.

The Fourier coefficients are computed using the FFT algorithm. They can then be filtered as per requirement. Percentage of power spectral density can be provided to capture significant features of the image. It can be reconstructed back on skewed axs to visualize the filtered image in Python or Julia.

Currently, this package supports only 2D data.