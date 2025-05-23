import { App, Widget } from "astal/gtk3"
import Sidebar from "./widget/Sidebar";
import style from "./style.scss"

App.start({
    main() {
        Sidebar();
    },

    css: style
})