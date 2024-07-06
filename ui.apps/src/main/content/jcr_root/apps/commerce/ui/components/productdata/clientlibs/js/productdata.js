/*
 Copyright 2024 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */
(function(document, $) {
    "use strict";
        // create a Coral select with multi select

        const form = document.getElementById('aem-assets-metadataeditor-formid');
        if (!form) {
            return;
        } 
        //add event listener to the input field
        const skuIdentifier = "commerce-product-skuid";
        const roleIdentifier = "commerce-product-role";
    if (form.getAttribute("product-data-listener-registered") !== "true") {
        $(document).on("change",`.${skuIdentifier}`, function(e) {
            let skuField = e.target;
            const roleField = skuField.nextElementSibling;
            let orderField = roleField;
            if (orderField?.classList.contains("commerce-product-order")) {
                orderField.setAttribute("name", './jcr:content/metadata/commerce:position');
                orderField.value = orderField.value || -1;
            }

        });
        const roleFieldName = "./jcr:content/metadata/commerce:roles";
        //add a change event listener to coral select
        $(document).on("change",`coral-select.${roleIdentifier}`, function(e) {
            let roleField = e.target;
            let inputField = roleField.querySelector(`input[name="${roleFieldName}"]`);
            if (!inputField) {
                inputField = document.createElement("input");
                inputField.setAttribute("type", "hidden");
                inputField.setAttribute("name", roleFieldName);
                roleField.appendChild(inputField);
            }
            //concatenate all selected values
            inputField.value = roleField.selectedItems.map(item => item.value).join(";");
        });
        form.setAttribute("product-data-listener-registered", "true");
    }

})(document, Granite.$);
