/*
 Copyright 2026 Adobe. All rights reserved.
 */
(function (document, Granite) {
    "use strict";

    var MSG_DUPLICATE = "Review the Commerce Alt Text, the store view code must be unique.";
    var MSG_BLANK_STORE = "Review the Commerce Alt Text, the store view code cannot be empty.";

    /** Avoid double alert if both click + custom event fire for the same save. */
    var lastAlertTs = 0;
    var ALERT_DEBOUNCE_MS = 800;
    var _$ = null;

    function storeViewKey(value) {
        return String(value || "").trim().toLowerCase();
    }

    function findForm(el) {
        if (!el) {
            return null;
        }
        var form = el.closest ? el.closest("#aem-assets-metadataeditor-formid") : null;
        return form || document.getElementById("aem-assets-metadataeditor-formid");
    }

    function clearAltTextRowStyles(form) {
        if (!form) {
            return;
        }
        form.querySelectorAll(".commerce-alttext-storeview").forEach(function (input) {
            input.classList.remove("commerce-alttext-storeview--duplicate", "commerce-alttext-storeview--blank-conflict");
        });
        form.querySelectorAll(".commerce-alttext-value").forEach(function (input) {
            input.classList.remove("commerce-alttext-value--duplicate", "commerce-alttext-value--blank-conflict");
        });
    }

    /**
     * Highlights invalid rows. Returns { valid, message } — message set only when valid is false.
     * Rules: (1) every row must have a non-empty store view; (2) duplicate store views (trimmed, case-insensitive) not allowed.
     */
    function validateAltTextRows(form) {
        if (!form) {
            return { valid: true, message: "" };
        }
        var fields = form.querySelectorAll(".commerce-alttext-storeview");
        if (fields.length === 0) {
            return { valid: true, message: "" };
        }

        clearAltTextRowStyles(form);

        var seen = {};
        var hasDuplicate = false;
        var hasEmpty = false;

        fields.forEach(function (input) {
            var key = storeViewKey(input.value);
            if (!key) {
                input.classList.add("commerce-alttext-storeview--blank-conflict");
                var row = input.closest(".commerce-alttext-row");
                if (row) {
                    var alt = row.querySelector(".commerce-alttext-value");
                    if (alt) {
                        alt.classList.add("commerce-alttext-value--blank-conflict");
                    }
                }
                hasEmpty = true;
            } else if (seen[key]) {
                input.classList.add("commerce-alttext-storeview--duplicate");
                seen[key].classList.add("commerce-alttext-storeview--duplicate");
                highlightAltRowPair(input, seen[key]);
                hasDuplicate = true;
            } else {
                seen[key] = input;
            }
        });

        if (hasEmpty) {
            return { valid: false, message: MSG_BLANK_STORE };
        }
        if (hasDuplicate) {
            return { valid: false, message: MSG_DUPLICATE };
        }
        return { valid: true, message: "" };
    }

    function highlightAltRowPair(a, b) {
        [a, b].forEach(function (input) {
            var row = input.closest(".commerce-alttext-row");
            if (row) {
                var alt = row.querySelector(".commerce-alttext-value");
                if (alt) {
                    alt.classList.add("commerce-alttext-value--duplicate");
                }
            }
        });
    }

    function showValidationAlert(message) {
        var now = Date.now();
        if (now - lastAlertTs < ALERT_DEBOUNCE_MS) {
            return;
        }
        lastAlertTs = now;
        var translated = (Granite && Granite.I18n) ? Granite.I18n.get(message) : message;
        if (_$) {
            var ui = _$(window).adaptTo("foundation-ui");
            if (ui && ui.alert) {
                ui.alert("", translated, "error");
                return;
            }
        }
        window.alert(translated);
    }

    /**
     * @returns {boolean} true if valid (allow save), false to block
     */
    function shouldAllowSave(form, showAlert) {
        if (!form) {
            return true;
        }
        var result = validateAltTextRows(form);
        if (result.valid) {
            return true;
        }
        if (showAlert) {
            showValidationAlert(result.message);
        }
        return false;
    }

    function onNativeSubmitCapture(e) {
        var form = e.target;
        if (form.id !== "aem-assets-metadataeditor-formid") {
            return;
        }
        if (!shouldAllowSave(form, true)) {
            e.preventDefault();
            e.stopPropagation();
            e.stopImmediatePropagation();
        }
    }

    function isMetadataFormVisible(form) {
        if (!form) {
            return false;
        }
        if (form.querySelectorAll(".commerce-alttext-storeview").length === 0) {
            return false;
        }
        var r = form.getBoundingClientRect();
        return r.width > 0 && r.height > 0;
    }

    function isSaveActionElement(el) {
        if (!el || !el.closest) {
            return false;
        }
        var btn = el.closest("button, coral-button, [is='coral-button']");
        if (!btn) {
            return false;
        }
        var text = (btn.textContent || "").replace(/\s+/g, " ").trim().toLowerCase();
        var title = (btn.getAttribute("title") || "").toLowerCase();
        var aria = (btn.getAttribute("aria-label") || "").toLowerCase();
        if (text === "save" || text.indexOf("save ") === 0 || title.indexOf("save") >= 0 || aria.indexOf("save") >= 0) {
            return true;
        }
        var icon = btn.getAttribute("icon") || (btn.icon ? btn.icon : "");
        if (icon && String(icon).indexOf("save") >= 0) {
            return true;
        }
        return false;
    }

    function onSaveClickCapture(e) {
        var form = document.getElementById("aem-assets-metadataeditor-formid");
        if (!form || !isMetadataFormVisible(form)) {
            return;
        }
        if (!isSaveActionElement(e.target)) {
            return;
        }
        if (!shouldAllowSave(form, true)) {
            e.preventDefault();
            e.stopPropagation();
            e.stopImmediatePropagation();
        }
    }

    function resolveMetadataForm(e) {
        var form = e.currentTarget;
        if (form && form.id === "aem-assets-metadataeditor-formid") {
            return form;
        }
        if (e.target && e.target.id === "aem-assets-metadataeditor-formid") {
            return e.target;
        }
        if (e.target && e.target.closest) {
            return e.target.closest("#aem-assets-metadataeditor-formid");
        }
        return document.getElementById("aem-assets-metadataeditor-formid");
    }

    function attachGraniteHooks($) {
        if (!$) {
            return;
        }
        _$ = $;
        var formSelector = "#aem-assets-metadataeditor-formid";
        var handler = function (e) {
            var form = resolveMetadataForm(e);
            if (!form || form.id !== "aem-assets-metadataeditor-formid") {
                return;
            }
            if (!shouldAllowSave(form, true)) {
                e.preventDefault();
                if (e.stopImmediatePropagation) {
                    e.stopImmediatePropagation();
                }
                return false;
            }
        };

        $(document).on("submit", formSelector, handler);
        /* Assets metadata often saves without a native submit; these cover Foundation paths. */
        $(document).on("foundation-form-submit", formSelector, handler);
        $(document).on("foundation-submit", formSelector, handler);
    }

    document.addEventListener("submit", onNativeSubmitCapture, true);

    document.addEventListener("click", onSaveClickCapture, true);

    document.addEventListener(
        "input",
        function (e) {
            if (!e.target || !e.target.classList) {
                return;
            }
            if (
                !e.target.classList.contains("commerce-alttext-storeview") &&
                !e.target.classList.contains("commerce-alttext-value")
            ) {
                return;
            }
            validateAltTextRows(findForm(e.target));
        },
        true
    );

    document.addEventListener(
        "blur",
        function (e) {
            if (!e.target || !e.target.classList || !e.target.classList.contains("commerce-alttext-storeview")) {
                return;
            }
            validateAltTextRows(findForm(e.target));
        },
        true
    );

    function initGranite() {
        var $ = Granite && Granite.$;
        if ($) {
            attachGraniteHooks($);
            return;
        }
        if (document.readyState === "loading") {
            document.addEventListener("DOMContentLoaded", function once() {
                document.removeEventListener("DOMContentLoaded", once);
                if (Granite && Granite.$) {
                    attachGraniteHooks(Granite.$);
                }
            });
        }
    }

    initGranite();
})(document, Granite);
