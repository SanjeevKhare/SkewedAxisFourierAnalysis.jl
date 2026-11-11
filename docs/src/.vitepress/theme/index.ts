import DefaultTheme from 'vitepress/theme'
import AngleExplorer from '../../components/AngleExplorer.vue'
import './style.css'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component('AngleExplorer', AngleExplorer)
  }
}
