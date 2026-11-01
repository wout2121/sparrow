package com.sparrowwallet.sparrow.control;

import com.sparrowwallet.sparrow.io.Config;

public class PublicServerTorSwitch extends UnlabeledToggleSwitch {
    public PublicServerTorSwitch() {
        setSelected(Config.get().isPublicServerTor());
        selectedProperty().addListener((observable, oldValue, newValue) -> Config.get().setPublicServerTor(newValue));
    }
}
