<%--
   Copyright 2026 Adobe. All rights reserved.
   This file is licensed to you under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License. You may obtain a copy
   of the License at http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software distributed under
   the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
   OF ANY KIND, either express or implied. See the License for the specific language
   governing permissions and limitations under the License.
--%>
<%@ include file="/libs/granite/ui/global.jsp" %>
<%@ page session="false"
         import="org.apache.commons.lang3.StringUtils,
                  org.apache.sling.api.resource.Resource,
                  com.adobe.granite.ui.components.AttrBuilder,
                  com.adobe.granite.ui.components.Config,
                  com.adobe.granite.ui.components.Field,
                  com.adobe.granite.ui.components.Tag" %>
<ui:includeClientLib categories="commerce.alttextmetadata" />
<%
    Config cfg = cmp.getConfig();
    ValueMap vm = (ValueMap) request.getAttribute(Field.class.getName());
    Field field = new Field(cfg);

    Tag tag = cmp.consumeTag();
    AttrBuilder attrs = tag.getAttrs();
    cmp.populateCommonAttrs(attrs);

    attrs.add("type", "text");
    attrs.add("is", "coral-textfield");

    String storeView = vm.get("value", String.class);
    String valueFieldName = cfg.get("valueField", "./jcr:content/metadata/commerce:altTextValues");
    String altTextValue = "";
    String contentPath = (String) request.getAttribute("granite.ui.form.contentpath");

    Integer indexAttr = (Integer) request.getAttribute("commerce.alttext.index");
    int index = 0;
    if (indexAttr != null) {
        index = indexAttr;
    } else {
%>
<input type="hidden" name="<%= cfg.get("name", String.class) %>@TypeHint" value="String[]"/>
<input type="hidden" name="<%= valueFieldName %>@TypeHint" value="String[]"/>
<%
    }

    if (contentPath != null) {
        Resource assetRes = resourceResolver.getResource(contentPath);
        if (assetRes != null) {
            ValueMap assetVM = assetRes.getValueMap();
            String[] values = assetVM.get(valueFieldName, new String[]{});
            altTextValue = values.length > index ? values[index] : "";
            request.setAttribute("commerce.alttext.index", index + 1);
        }
    }
%>
<div class="commerce-alttext-row">
<input <%= attrs.build() %> value="<%= xssAPI.encodeForHTMLAttr(storeView != null ? storeView : "") %>" class="commerce-alttext-storeview" name="<%= cfg.get("name", String.class) %>" placeholder="<%= i18n.get("Store View") %>"/>
<input is="coral-textfield" value="<%= xssAPI.encodeForHTMLAttr(altTextValue) %>" class="commerce-alttext-value" name="<%= valueFieldName %>" maxlength="255" placeholder="<%= i18n.get("Alt Text") %>"/>
</div>
