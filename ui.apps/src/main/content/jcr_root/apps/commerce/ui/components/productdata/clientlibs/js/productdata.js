/*
 Copyright 24 Adobe. All rights reserved.
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
            const fieldName = skuField.value.replaceAll("/", "_");
            if (roleField?.classList.contains(roleIdentifier)) {
                roleField.setAttribute("name", `./jcr:content/metadata/commerce-mapping/${fieldName}/role`);
                orderField = roleField.nextElementSibling;
                console.log(`role changed to ./jcr:content/metadata/commerce-mapping/${fieldName}/role`);
            }
            if (orderField.classList.contains("commerce-product-order")) {
                orderField.setAttribute("name", `./jcr:content/metadata/commerce-mapping/${fieldName}/order`);
            }

        });
        form.setAttribute("product-data-listener-registered", "true");
    }
    else {
        console.log("listener already registered");
    }

})(document, Granite.$);
