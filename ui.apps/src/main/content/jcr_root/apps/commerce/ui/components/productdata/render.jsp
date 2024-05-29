<%--
   Copyright 2024 Adobe. All rights reserved.
   This file is licensed to you under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License. You may obtain a copy
   of the License at http://www.apache.org/licenses/LICENSE-2.0
   
   Unless required by applicable law or agreed to in writing, software distributed under
   the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
   OF ANY KIND, either express or implied. See the License for the specific language
   governing permissions and limitations under the License.
--%><%
%><%@ include file="/libs/granite/ui/global.jsp" %><%
%><%@ page session="false"
          import="org.apache.commons.lang3.StringUtils,
                  com.adobe.granite.ui.components.AttrBuilder,
                  com.adobe.granite.ui.components.Config,
                  com.adobe.granite.ui.components.Field,
                  com.adobe.granite.ui.components.Tag" %><%--###
TextField
=========

.. granite:servercomponent:: /libs/granite/ui/components/coral/foundation/form/textfield
   :supertype: /libs/granite/ui/components/coral/foundation/form/field

   A text field component.

   It extends :granite:servercomponent:`Field </libs/granite/ui/components/coral/foundation/form/field>` component.

   It has the following content structure:

   .. gnd:gnd::

      [granite:FormTextField] > granite:FormField

      /**
       * The name that identifies the field when submitting the form.
       */
      - name (String)

      /**
       * The value of the field.
       */
      - value (StringEL)

      /**
       * A hint to the user of what can be entered in the field.
       */
      - emptyText (String) i18n

      /**
       * Indicates if the field is in disabled state.
       */
      - disabled (Boolean)

      /**
       * Indicates if the field is mandatory to be filled.
       */
      - required (Boolean)

      /**
       * Indicates if the value can be automatically completed by the browser.
       *
       * See also `MDN documentation regarding autocomplete attribute <https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input>`_.
       */
      - autocomplete (String) = 'off'

      /**
       * The ``autofocus`` attribute to lets you specify that the field should have input focus when the page loads,
       * unless the user overrides it, for example by typing in a different control.
       * Only one form element in a document can have the ``autofocus`` attribute.
       */
      - autofocus (Boolean)

      /**
       * The name of the validator to be applied. E.g. ``foundation.jcr.name``.
       * See :doc:`validation </jcr_root/libs/granite/ui/components/coral/foundation/clientlibs/foundation/js/validation/index>` in Granite UI.
       */
      - validation (String) multiple

      /**
       * The maximum number of characters (in Unicode code points) that the user can enter.
       */
      - maxlength (Long)
###--%><ui:includeClientLib categories="commerce.productmetadata" /><%

    Config cfg = cmp.getConfig();
    ValueMap vm = (ValueMap) request.getAttribute(Field.class.getName());
    Field field = new Field(cfg);

    boolean isMixed = field.isMixed(cmp.getValue());

    Tag tag = cmp.consumeTag();
    AttrBuilder attrs = tag.getAttrs();
    cmp.populateCommonAttrs(attrs);

    attrs.add("type", "text");
    attrs.add("aria-label", i18n.getVar(cfg.get("emptyText", String.class)));
    attrs.addBoolean("autofocus", cfg.get("autofocus", false));

    String fieldLabel = cfg.get("fieldLabel", String.class);
    String fieldDesc = cfg.get("fieldDescription", String.class);
    String labelledBy = null;

    if (fieldLabel != null && fieldDesc != null) {
        labelledBy = vm.get("labelId", String.class) + " " + vm.get("descriptionId", String.class);
    } else if (fieldLabel != null) {
        labelledBy = vm.get("labelId", String.class);
    } else if (fieldDesc != null) {
        labelledBy = vm.get("descriptionId", String.class);
    }

    if (StringUtils.isNotBlank(labelledBy)) {
        attrs.add("labelledby", labelledBy);
    }
    attrs.add("maxlength", cfg.get("maxlength", Integer.class));

    if (cfg.get("required", false)) {
        attrs.add("aria-required", true);
    }

    String validation = StringUtils.join(cfg.get("validation", new String[0]), " ");
    attrs.add("data-foundation-validation", validation);
    attrs.add("data-validation", validation); // Compatibility
    String contentPath =  (String)request.getAttribute("granite.ui.form.contentpath");
    log.info("in commerce metadata component contentPath: " + request.getAttribute("granite.ui.form.contentpath"));
    // @coral
    attrs.add("is", "coral-textfield");
    String sku = vm.get("value", String.class);
    String roleFieldName = null;
    String orderFieldName = null;
    String roleValue = "";
    String orderValue = "";
    boolean showRole = "true".equals(cfg.get("showRoles", ""));
    boolean showOrder = "true".equals(cfg.get("showOrder", ""));
    if (sku != null) {
        roleFieldName = String.format("./jcr:content/metadata/commerce-mapping/%s/role", sku.replaceAll("/", "_"));
        orderFieldName = String.format("./jcr:content/metadata/commerce-mapping/%s/order", sku.replaceAll("/", "_"));
        if (contentPath != null) {
             ValueMap assetVM = resourceResolver.getResource(contentPath).getValueMap();
             roleValue = assetVM.get(roleFieldName, "");
             orderValue = assetVM.get(orderFieldName, "");
        }
    }

%><input <%= attrs.build() %> value='<%=sku %>' class='commerce-product-skuid'  name='<%= cfg.get("name", String.class) %>' placeholder='<%= i18n.get("Product SKU") %>'>
<% if (showRole) { %>
       <input <%= attrs.build() %> value='<%=roleValue %>' class='commerce-product-role' name='<%=roleFieldName %>' placeholder='<%= i18n.get("Role") %>'>
<% } else { %>
   <!-- input <%= attrs.build() %> disabled value='<%=roleValue %>' class='commerce-product-role' name='<%=roleFieldName %>' placeholder='<%= i18n.get("Role") %>'-->
<% } 
   if (showOrder) { %>
       <input <%= attrs.build() %> value='<%=orderValue %>'class='commerce-product-order' name='<%=orderFieldName %>' data-metatype="number" data-validation='cui.number'  placeholder='<%= i18n.get("Order") %>'>
<% } %>