import { defineConfig } from 'vitepress'

export default defineConfig({
  base: 'REPLACE_ME_DOCUMENTER_VITEPRESS',
  title: 'SkewedAxisFourierAnalysis.jl',
  description: 'From skewed lattice images to compact Fourier models in Julia.',
  outDir: 'REPLACE_ME_DOCUMENTER_VITEPRESS',
  cleanUrls: false,
  lastUpdated: true,
  vite: { assetsInclude: ['**/*.jl', '**/*.txt'] },
  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: '/SkewedAxisFourierAnalysis.jl/dev/logo.svg' }],
    ['meta', { name: 'theme-color', content: '#5145b8' }]
  ],
  markdown: { math: true, theme: { light: 'github-light', dark: 'github-dark' } },
  themeConfig: {
    logo: '/logo.svg',
    siteTitle: 'SkewedAxisFourierAnalysis.jl',
    outline: [2, 3],
    search: { provider: 'local', options: { detailedView: true } },
    nav: [
      { text: 'Get started', link: '/guide/getting-started' },
      { text: 'Tutorials', link: '/tutorials/synthetic' },
      { text: 'The method', link: '/guide/coordinates' },
      { text: 'API', link: '/reference/api' }
    ],
    sidebar: 'REPLACE_ME_DOCUMENTER_VITEPRESS',
    socialLinks: [{ icon: 'github', link: 'https://github.com/SanjeevKhare/SkewedAxisFourierAnalysis.jl' }],
    editLink: {
      pattern: ({ relativePath }) => {
        const path = relativePath.startsWith('tutorials/')
          ? 'docs/examples/' + relativePath.split('/').pop().replace(/\.md$/, '.jl')
          : 'docs/src/' + relativePath
        return 'https://github.com/SanjeevKhare/SkewedAxisFourierAnalysis.jl/edit/main/' + path
      },
      text: 'Edit this page on GitHub'
    },
    footer: {
      message: 'Open source · Two-dimensional Fourier analysis · Built with Julia',
      copyright: 'Sanjeev Khare and contributors · MIT License'
    }
  },
  sitemap: { hostname: 'https://sanjeevkhare.github.io/SkewedAxisFourierAnalysis.jl/dev/' }
})
