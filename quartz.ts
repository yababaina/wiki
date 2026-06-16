import { loadQuartzConfig, loadQuartzLayout } from "./quartz/plugins/loader/config-loader"
import { registerCondition } from "./quartz/plugins/loader/conditions"
import * as ExternalPlugin from "./.quartz/plugins"
registerCondition("index-only", (props) => props.fileData.slug === "index")
ExternalPlugin.RecentNotes({
  filter: (file) => file.slug !== "404",
})
const config = await loadQuartzConfig()
export default config
export const layout = await loadQuartzLayout()