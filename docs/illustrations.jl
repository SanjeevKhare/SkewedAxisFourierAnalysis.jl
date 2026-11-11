# Generate a schematic hero from an analytically sampled periodic field.
using ColorSchemes
using Images

output = joinpath(@__DIR__, "src", "public", "hero.svg")
open(output, "w") do io
    println(io, """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 460" role="img" aria-labelledby="title desc"><title id="title">From a lattice to its harmonics</title><desc id="desc">Analytically sampled periodic field with a schematic Fourier-peak inset and a skewed cell outline.</desc><defs><clipPath id="field"><rect width="320" height="280" rx="14"/></clipPath><filter id="shadow" x="-30%" y="-30%" width="160%" height="160%"><feDropShadow dx="0" dy="12" stdDeviation="16" flood-color="#353057" flood-opacity=".13"/></filter></defs><rect x="30" y="75" width="390" height="342" rx="24" fill="#fff" filter="url(#shadow)"/><text x="58" y="107" font-family="sans-serif" font-size="12" font-weight="700" letter-spacing="2" fill="#5145b8">REAL SPACE</text><g transform="translate(60 122)" clip-path="url(#field)">""")
    for iy in 0:69, ix in 0:79
        u, v = ix / 80, iy / 70
        f = 0.8 + 0.65cos(2π * (2u + v) + 0.4) + 0.3cos(2π * (-u + 3v) - 0.6)
        c = get(ColorSchemes.viridis, clamp((f + 0.15) / 1.9, 0, 1))
        color = "#" * join(string(round(Int, 255a); base = 16, pad = 2) for a in (red(c), green(c), blue(c)))
        println(io, "<rect x='$(4ix)' y='$(4iy)' width='4.1' height='4.1' fill='$color'/>")
    end
    println(io, """<path d="M50 230H210L270 65H110Z" fill="none" stroke="white" stroke-width="2" opacity=".85"/></g><rect x="342" y="28" width="208" height="209" rx="20" fill="#19192c" filter="url(#shadow)"/><text x="365" y="60" font-family="sans-serif" font-size="11" font-weight="700" letter-spacing="1.7" fill="#c9c4ff">FOURIER SPACE</text><g stroke="#626078" stroke-width=".6" opacity=".6"><path d="M370 140h150M445 85v115"/><path d="M370 110h150M370 170h150M408 85v115M482 85v115"/></g><g fill="#8dd8c6"><circle cx="445" cy="140" r="6"/><circle cx="482" cy="125" r="4"/><circle cx="408" cy="155" r="4"/><circle cx="426" cy="95" r="3"/><circle cx="464" cy="185" r="3"/></g><path d="M432 280h90" stroke="#8a81bd" stroke-width="1.5"/><text x="432" y="309" font-family="sans-serif" font-size="13" fill="#77718f">pixels → modes</text><rect x="315" y="345" width="236" height="65" rx="13" fill="#eeebfb"/><text x="333" y="372" font-family="sans-serif" font-size="12" fill="#5145b8">ONE COMPACT MODEL</text><text x="333" y="394" font-family="monospace" font-size="14" fill="#37304f">(i, j, magnitude, phase)</text></svg>""")
end
