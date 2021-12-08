<script>const _= 
(()=>{

    const out = 
${ftl_object_to_js_code_declaring_an_object(.data_model, [])?no_esc};

    out["msg"]= function(){ throw new Error("use import { useKcMessage } from 'keycloakify'"); };
    out["advancedMsg"]= function(){ throw new Error("use import { useKcMessage } from 'keycloakify'"); };

    out["messagesPerField"]= {
        <#assign fieldNames = [
            "global", "userLabel", "username", "email", "firstName", "lastName", "password", "password-confirm",
            "totp", "totpSecret", "SAMLRequest", "SAMLResponse", "relayState", "device_user_code", "code", 
            "password-new", "rememberMe", "login", "authenticationExecution", "cancel-aia", "clientDataJSON", 
            "authenticatorData", "signature", "credentialId", "userHandle", "error", "authn_use_chk", "authenticationExecution", 
            "isSetRetry", "try-again", "attestationObject", "publicKeyCredentialId", "authenticatorLabel"
        ]>
    
        <#attempt>
            <#if profile?? && profile.attributes?? && profile.attributes?is_enumerable>
                <#list profile.attributes as attribute>
                    <#if fieldNames?seq_contains(attribute.name)>
                        <#continue>
                    </#if>
                    <#assign fieldNames += [attribute.name]>
                </#list>
            </#if>
        <#recover>
        </#attempt>
    
        "printIfExists": function (fieldName, x) {
            <#list fieldNames as fieldName>
                if(fieldName === "${fieldName}" ){
                    <#attempt>
                        return "${messagesPerField.printIfExists(fieldName,'1')}" ? x : undefined;
                    <#recover>
                    </#attempt>
                }
            </#list>
            throw new Error("There is no " + fieldName + " field");
        },
        "existsError": function (fieldName) {
            <#list fieldNames as fieldName>
                if(fieldName === "${fieldName}" ){
                    <#attempt>
                        return <#if messagesPerField.existsError('${fieldName}')>true<#else>false</#if>;
                    <#recover>
                    </#attempt>
                }
            </#list>
            throw new Error("There is no " + fieldName + " field");
        },
        "get": function (fieldName) {
            <#list fieldNames as fieldName>
                if(fieldName === "${fieldName}" ){
                    <#attempt>
                        <#if messagesPerField.existsError('${fieldName}')>
                            return "${messagesPerField.get('${fieldName}')?no_esc}";
                        </#if>
                    <#recover>
                    </#attempt>
                }
            </#list>
            throw new Error("There is no " + fieldName + " field");
        },
        "exists": function (fieldName) {
            <#list fieldNames as fieldName>
                if(fieldName === "${fieldName}" ){
                    <#attempt>
                        return <#if messagesPerField.exists('${fieldName}')>true<#else>false</#if>;
                    <#recover>
                    </#attempt>
                }
            </#list>
            throw new Error("There is no " + fieldName + " field");
        }
    };

    return out;

})();
<#function ftl_object_to_js_code_declaring_an_object object path>

        <#local isHash = "">
        <#attempt>
            <#local isHash = object?is_hash || object?is_hash_ex>
        <#recover>
            <#return "ABORT: Can't evaluate if " + path?join(".") + " is hash">
        </#attempt>

        <#if isHash>

            <#if path?size gt 10>
                <#return "ABORT: Too many recursive calls">
            </#if>

            <#local keys = "">

            <#attempt>
                <#local keys = object?keys>
            <#recover>
                <#return "ABORT: We can't list keys on this object">
            </#attempt>


            <#local out_seq = []>

            <#list keys as key>

                <#if ["class","declaredConstructors","superclass","declaringClass" ]?seq_contains(key) >
                    <#continue>
                </#if>

                <#if 
                    ["loginUpdatePasswordUrl", "loginUpdateProfileUrl", "loginUsernameReminderUrl", "loginUpdateTotpUrl"]?seq_contains(key) && 
                    path?map(x -> x?is_number?string("_index_",x))?join("°") == ["url"]?join("°")
                >
                    <#local out_seq += ["/*If you need" + key + " please submit an issue to the Keycloakify repo*/"]>
                    <#continue>
                </#if>

                <#attempt>
                    <#if !object[key]??>
                        <#continue>
                    </#if>
                <#recover>
                    <#local out_seq += ["/*Couldn't test if '" + key + "' is available on this object*/"]>
                    <#continue>
                </#attempt>

                <#local propertyValue = "">

                <#attempt>
                    <#local propertyValue = object[key]>
                <#recover>
                    <#local out_seq += ["/*Couldn't dereference '" + key + "' on this object*/"]>
                    <#continue>
                </#attempt>

                <#local rec_out = ftl_object_to_js_code_declaring_an_object(propertyValue, path + [ key ])>

                <#if rec_out?starts_with("ABORT:")>

                    <#local errorMessage = rec_out?remove_beginning("ABORT:")>

                    <#if errorMessage != " It's a method" >
                        <#local out_seq += ["/*" + key + ": " + errorMessage + "*/"]>
                    </#if>

                    <#continue>
                </#if>

                <#local out_seq +=  ['"' + key + '": ' + rec_out + ","]>

            </#list>

            <#return (["{"] + out_seq?map(str -> ""?right_pad(4 * (path?size + 1)) + str) + [ ""?right_pad(4 * path?size) + "}"])?join("\n")>

        </#if>

        <#local isMethod = "">
        <#attempt>
            <#local isMethod = object?is_method>
        <#recover>
            <#return "ABORT: Can't test if it'sa method.">
        </#attempt>

        <#if isMethod>
            <#return "ABORT: It's a method">
        </#if>

        <#local isBoolean = "">
        <#attempt>
            <#local isBoolean = object?is_boolean>
        <#recover>
            <#return "ABORT: Can't test if it's a boolean">
        </#attempt>

        <#if isBoolean>
            <#return object?c>
        </#if>

        <#local isEnumerable = "">
        <#attempt>
            <#local isEnumerable = object?is_enumerable>
        <#recover>
            <#return "ABORT: Can't test if it's an enumerable">
        </#attempt>


        <#if isEnumerable>

            <#local out_seq = []>

            <#local i = 0>

            <#list object as array_item>

                <#local rec_out = ftl_object_to_js_code_declaring_an_object(array_item, path + [ i ])>

                <#local i = i + 1>

                <#if rec_out?starts_with("ABORT:")>

                    <#local errorMessage = rec_out?remove_beginning("ABORT:")>

                    <#if errorMessage != " It's a method" >
                        <#local out_seq += ["/*" + i?string + ": " + errorMessage + "*/"]>
                    </#if>

                    <#continue>
                </#if>

                <#local out_seq += [rec_out + ","]>

            </#list>

            <#return (["["] + out_seq?map(str -> ""?right_pad(4 * (path?size + 1)) + str) + [ ""?right_pad(4 * path?size) + "]"])?join("\n")>

        </#if>

        <#attempt>
            <#return '"' + object?js_string + '"'>;
        <#recover>
        </#attempt>

        <#return "ABORT: Couldn't convert into string non hash, non method, non boolean, non enumerable object">

</#function>
</script>