import { Astal, App } from "astal/gtk4";
import Brightness from "../helper/Brightness";
import { bind, execAsync } from "astal";
import Wp from "gi://AstalWp";

// How to not hardcode ~

function BrightnessSlider() {
    const brightness = Brightness.get_default();

    return(
        <slider
            className="GenericSlider"
            hexpand
            value={bind(brightness, "screen")}
            onDragged={ ({ value }) => brightness.screen = value }
        />
    );
}

function AudioSlider() {
    const speaker = Wp.get_default()!.audio.defaultSpeaker; // is this always the case?

    return(
        <slider 
        className="GenericSlider"
            hexpand
            onDragged={ ({ value }) => speaker.volume = value }
            value={bind(speaker, "volume")}
        />
    );
}

function Button({ onClick, className, label }: any) {
    return(
        <button
            onClick={onClick}
            className={className}
        >
            <label label={label} />
        </button>
    )
}

export default function Sidebar() {
    return(
        <window
            name="sidebar"
            className="sidebar"
            application={App}
            visible
            anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT}
        >
            <box>
                <box>
                    <Button 
                        onClick={() => execAsync("pavucontrol")}
                        label={"Audio"}
                        className={"audio-button"}
                    />
                    <Button 
                        onClick={() => execAsync("blueman-manager")}
                        label={"Bluetooth"}
                        className={"bluetooth-button"}
                    />
                    <Button 
                        onClick={() => execAsync("/usr/home/nekros/.config/ml4w/settings/system-monitor.sh").catch(e => print(e))}
                        label={"HTOP"}
                        className={"htop-button"}
                    />
                </box>
                <box>
                    <AudioSlider />
                    <BrightnessSlider />
                </box>
                <box>
                    <Button
                        onClick={""}
                        label="Do not disturb"
                        className="dnd-button"
                    />
                    <Button
                        onClick={""}
                        label="Do not disturb"
                        className="dnd-button"
                    />
                    <Button
                        onClick={""}
                        label="Animations"
                        className="animations-button"
                    />
                </box>
            </box>
        </window>
    )
}