<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@page isELIgnored="false"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<c:set var="ctxPath" value="${pageContext.request.contextPath}/" />
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="${ctxPath}css/ui-lightness/jquery-ui-1.10.4.custom.min.css">
<link type='text/css' rel="stylesheet" href="${ctxPath}css/jquery-ui-timepicker-addon.css">
<link rel="stylesheet" href="${ctxPath}css/focus.css">
<link rel="stylesheet" href="${ctxPath}css/jCrop/jquery.Jcrop.css">
<style>
/* 	focus.css這檔案改了很多基本元素的style..這裡把它修正回來 */
	#imageCrop div{
		margin-top: 0px;
		margin-bottom: 0px;
	}
	#imageCrop img{
		width: auto;
	}
	.jcrop-keymgr{
		visibility:hidden;
	}
	#keywordTable.draggable td{
		cursor:auto;
	}
</style>  
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/lodash/4.17.4/lodash.min.js"></script>
<script src="${ctxPath}js/3rd/jquery-1.10.2.js"></script>
<script src="${ctxPath}js/3rd/jquery-ui-1.10.4.custom.min.js"></script>
<script src="${ctxPath}js/3rd/jquery-ui-timepicker-addon.js"></script>
<script src="${ctxPath}js/3rd/jquery-ui-sliderAccess.js"></script>
<script src="${ctxPath}js/3rd/jCrop/jquery.Jcrop.js"></script>
<script src="${ctxPath}js/ckEditor.js"></script>
<script src="${ctxPath}js/base64.js"></script>
<script src="${ctxPath}js/dragAndDrop.js"></script>
<title>小編推薦設定</title>
<script>
    $(function() {
    	var optActive= { dateFormat: 'yy-mm-dd',    			         
    			         timeFormat: 'HH:mm:ss',    			         
    			         oneLine: true,
                         showSecond: true,
                         showMillisec: false,
                         showMicrosec: false,
                         showTimezone: false,
                         controlType:"select",
                         beforeShow: function (input, inst) {
                             setTimeout(function () {
                                 inst.dpDiv.css({ 
                                     "z-index" : 1000,
                                 });
                             }, 0);
                         }
                       };
    	
    	var optInactive= { dateFormat: 'yy-mm-dd',
    			           timeFormat: 'HH:mm:ss',                           
                           oneLine: true,
                           showSecond: true,
                           showMillisec: false,
                           showMicrosec: false,
                           showTimezone: false,
                           controlType:"select",
                           beforeShow: function (input, inst) {
                               setTimeout(function () {
                                   inst.dpDiv.css({ 
                                       "z-index" : 1000,
                                   });
                               }, 0);
                           }
                         };
        $("#activeDate").datetimepicker(optActive);
        
        $("#inactiveDate").datetimepicker(optInactive);
        
    });
    
    $(function() {
        var options = [];
        $.ajax({
            url: "/NewStoreAdmin/ajax/cms/getManageGroup",
            success: function(data) {
                var stpAccount = $("#userAccount").val();
                var role = $("#role").val();
                if ('PM' === role.toUpperCase()){
                    stpAccount = 'CIT01';
//                     stpAccount = 'TWM01110';
                }
                for (var key in data) {
                    if (stpAccount && !key.startsWith(stpAccount)) {
                        continue;
                    }
                    var magGroup = {};
                    magGroup.groupId = key;
                    magGroup.groupDesc = data[key];
                    options.push(magGroup);
            	}
             optionsAdd(options);
            }
        });
    });
    
    
    //延伸閱讀區
    var numberOfExtendBook = "${curatorRecommend.curatorExtBooks.size()}";
    function addExtendBook() {
        var extendBook = $('#extendBook').val();
        var isDuplicate = checkDuplicate(extendBook);
        if(extendBook.trim() == '') {
            alert('請輸入延伸閱讀書籍contenId');
        } else if(isDuplicate) {
            alert('書籍重複新增，請確認!');
        } else if(numberOfExtendBook === 10) {
            alert('延伸閱讀書籍不可設定超過10本');
        } else {
        	$.ajax({url: "/NewStoreAdmin/ajax/getExtendBook", 
        		    data: {contentId: extendBook}, 
        		    success: function(result){
        		    	
                if(result.status === 'success') {
                    if(!result.data.isVisible) {
                        alert('「'+result.data.contentName+'('+result.data.contentId+')」不顯示為露出');
                    } 
                    var dom = '';
                    dom += '<tr class="dataExtBooks" draggable="true">';
                    dom += '    <td class="rid invisible">'+'</td>';
                    dom += '    <td class="nowDisplayOrder invisible">'+numberOfExtendBook+'</td>';
                    dom += '    <td class="originDisplayOrder invisible">'+'</td>';
                    dom += '    <td class="contentId">'+result.data.contentId+'</td>';
                    dom += '    <td class="contentName">'+result.data.contentName+'</td>'; 
                    dom += '    <td style="display:none" class="serviceId">'+result.data.serviceId+'</td>';
                    dom += '    <td class="serviceName">'+result.data.serviceName+'</td>';  
                    dom += '    <td><a nohref onclick="deleteExtBook(\''+result.data.contentId+'\')">刪除</a></td>';
                    dom += '</tr>';
                    $('#draggableExtBook > tbody').append(dom);
                    numberOfExtendBook++;
                    reSort();
                } else {
                    alert(result.message);
                }        	 
            }});
        }
    }    
    //檢查重複書籍
    function checkDuplicate(contentId) {
        var result = false;
        $('tbody tr').each(function() {
            var tableContentId = $(this).find('.contentId').text();
            if(contentId === tableContentId) {
                result = true;
            }
        });
        return result;
    }
    //刪除延伸閱讀書籍
    function deleteExtBook(contentId) {
        var row = $(".dataExtBooks").children(".contentId:contains('"+contentId+"')").parent();
        $(row).remove();
        numberOfExtendBook -= 1;
        reSort();
    }
    
    function optionsAdd(options){
        var selectBox = document.getElementById('publisher');
        for(var i = 0; i < options.length; i++){
          var option = options[i];
          selectBox.options.add( new Option(option.groupDesc, option.groupId) );
        }
    }
    
</script>
</head>
<body>
<%@ include file="../../menuBar.jsp" %>
<div class="container">
		<c:if test="${mode == 'add'}">
			<h1>新增文章</h1>
		</c:if>
		<c:if test="${mode == 'modify'}">
			<h1>編輯文章</h1>
		</c:if>
		<hr>
		<input id="account" type="hidden" value="newStoreAdmin" />		
		<input id="userAccount" type="hidden" value="${userAccount}" />		
		<input id="role" type="hidden" value="${role}" />		
	    <input id="curatorArticleRid" name="curatorArticleRid" type="hidden" value="0">				
		<input id="authorToken" type="hidden" value="0">
		<input id="ckEditorOpenUrl" type="hidden" value="${ckEditorOpenUrl}" />
        <input id="ckEditorGetridUrl" type="hidden" value="${ckEditorGetridUrl}" />
        <input id="ckEditorGetdataUrl" type="hidden" value="${ckEditorGetdataUrl}" />
		
	<form:form action="save" method="POST" commandName="curatorRecommend" id="curatorRecommend" name="curatorRecommend" 
	    enctype="multipart/form-data" class="col-xs-6 form-horizontal">
		<form:hidden path="rid" />
		<form:hidden path="location" />		
		<form:hidden path="createDate" />		
		<form:hidden path="articleId" />
		<form:hidden path="createUser" />
        <input id="titleId" type="hidden" value="${rid}" />
<%--         <input id="account" type="hidden" value="${curatorRecommend.createUser}" /> --%>
        
		<div class="form-group">
			<font color=black size=-2>*</font>出版社：
			<select  class="form-control" id ="publisher">
			</select>
		</div>
		<div class="form-group">
			<form:label path="title">*小編推薦標題:</form:label>
			<form:textarea class="form-control" path="title" size="100" />
			<font color="red" size="2"><form:errors path="title" /></font>
		</div>
		
		<div class="form-group">
			<form:label path="activeDate">*上架日期（例如:2014-01-01）:</form:label>
			<form:input class="form-control" path="activeDate" id="activeDate" maxlength="19" placeholder="YYYY-MM-DD HH:mm:ss"/>
			<font color="red" size="2"><form:errors path="activeDate" /></font>
		</div>
		<div class="form-group">			
			<form:label path="inactiveDate">*下架日期（例如:2014-01-01）:</form:label>
			<form:input class="form-control" path="inactiveDate" id="inactiveDate" maxlength="19" placeholder="YYYY-MM-DD HH:mm:ss" />
			<font color="red" size="2"><form:errors path="inactiveDate" /></font>
		</div>
		<br/>
		<div class="form-group">
			<form:label path="innerContent">*小編推薦內文:</form:label>						
			<form:input class="form-control" type="hidden" name="articleDesc" path="articleDesc" />
            <input type="button" value="編輯" onClick="openCkeditor()">			
			<font color="red" size="2"><form:errors path="innerContent" /></font>
		</div>
		
<!-- 		<div class="form-group"> -->
<!-- 			<label>*露出版位:</label><br /> -->
<%-- 			<label class="checkbox-inline"><form:radiobutton path="showingZone" name="showingZone" value="book" />電子書館</label> --%>
<%-- 			<label class="checkbox-inline"><form:radiobutton path="showingZone" name="showingZone" value="magazine" />雜誌館</label> --%>
<%-- 			<label class="checkbox-inline"><form:radiobutton path="showingZone" name="showingZone" value="comic" />漫畫館</label> --%>
<%-- 			<font color="red" size="2"><form:errors path="showingZone" /></font> --%>
<!-- 		</div> -->
		
<!-- 		<div class="form-group" style="display:none"> -->
<!-- 			<label>*授權露出:</label><br /> -->
<%-- 			<label class="checkbox-inline"><form:radiobutton path="isPaid" name="isPaid" value="N" />未付費、已付費用戶</label> --%>
<%-- 			<label class="checkbox-inline"><form:radiobutton path="isPaid" name="isPaid" value="Y" />僅已付費用戶</label> --%>
<%-- 			<font color="red" size="2"><form:errors path="showingZone" /></font> --%>
<!-- 		</div> -->
		
		<div class="form-group">
			<label>*文章分類:</label><br />
			<c:forEach items="${curatorRecommend.articleCategoryList}" var="articleCategory">
			<label class="checkbox-inline" style="margin-left:10px" ><input type="checkbox" name="articleCategoryChecked" value="${articleCategory.categoryCode}" <c:if test = "${articleCategory.isChecked}"> checked </c:if>/>${articleCategory.name}</label>
			</c:forEach>
		</div>
		
<!-- 		<div class="form-group"> -->
<!-- 			<label for="file">*小編推薦圖:</label> -->
<!-- 			<br/> -->
<!-- 			<input id="getContentImage" type="button" style="padding:1px;margin-left:5px" value="取得內文首張圖" >  -->
<!-- 			<input id="articleDescImage" name="articleDescImage" type="hidden" /> -->
<!-- 			<br/> -->
<!-- 			<input id="bannerFile" type="file" name="bannerFile" id="file" size="50" /> -->
<%-- 			<font color="red" size="2">${fileUploadError}</font>  --%>
<!-- 			<font color="red" size="2">列表頁尺寸:272x209(請統一上傳此尺寸圖片)</font><br> -->
<!-- 			<font color="red" size="2">首頁尺寸:170x130</font><br>	 -->

<%-- 				<img id="bannerImg" src="${bannerImg}" /> --%>

<!-- 		</div> -->
		
		<div class="col-xs-12 invisible">        
        <form:input class="col-xs-3" path="curatorExtBooksJson" id="curatorExtBooksJson" name="curatorExtBooksJson" />
        <form:input class="col-xs-3" path="curatorExtBooksSize" id="curatorExtBooksSize" name="curatorExtBooksSize" />
        </div>
        
        <hr class="col-xs-12">
        
		<div class="col-xs-12">
			<h3 class="mgt5"><b>本文關鍵字:</b></h3>
			<input id="keywordInput" class="col-xs-6" type="text" >
            <input type="button" id="btnAddKeyword" value="新增" class="col-xs-2">
            <br/>
            <br/>
			<div class="table-responsive">
				<table id="keywordTable" class="table draggable" >
					<thead>
						<tr>
							<th>關鍵字</th>
							<th>操作</th>
						</tr>
					</thead>
					<tbody>
					<c:forEach var = "articleKeyword" items="${curatorRecommend.articleKeywordList}">
						<tr>
							<td name="keywordValue"><c:out value = "${articleKeyword}"/></td>
							<td><a>刪除</a></td>
						</tr>
					</c:forEach>
					</tbody>
				</table>
			</div>
		</div>
		<hr class="col-xs-12">
		<div class="col-xs-12">
			<h3 class="mgt5"><b>延伸閱讀:</b></h3><br/>
			<input id="extendBook" class="col-xs-6" type="text" >
            <input type="button" id="btnAddExtbook" value="新增" class="col-xs-2" onClick="addExtendBook()">
            <font color="red" size="2"><form:errors path="extendContent" /></font>
            <br/><br/>
			<div class="table-responsive">
             <table class="table draggable" id="draggableExtBook">
              <thead>
                  <tr>
                    <th class="invisible">rid</th>
                      <th class="invisible">排序</th>
                      <th class="invisible">原始排序</th>
                      <th>contentId</th>
                      <th>書籍名稱</th>    
                      <th>樂讀包名稱</th>                   
                      <th>操作</th>
                  </tr>
              </thead>
              <tbody>
                <c:if test="${curatorRecommend.curatorExtBooks.size() > 0}">
                <c:forEach var = "i" begin = "0" end = "${curatorRecommend.curatorExtBooks.size()-1}">
                  <tr class="dataExtBooks" draggable="true">
                    <td class="rid invisible"><c:out value = "${curatorRecommend.curatorExtBooks[i].rid}"/></td>
                    <td class="nowDisplayOrder invisible"><c:out value = "${curatorRecommend.curatorExtBooks[i].displayOrder}"/></td>
                    <td class="originDisplayOrder invisible"><c:out value = "${curatorRecommend.curatorExtBooks[i].displayOrder}"/></td>
                    <td class="contentId"><c:out value = "${curatorRecommend.curatorExtBooks[i].contentId}"/></td>
                    <td class="contentName"><c:out value = "${curatorRecommend.curatorExtBooks[i].contentName}"/></td>
                    <td style="display:none" class="serviceId"><c:out value = "${curatorRecommend.curatorExtBooks[i].serviceId}"/></td>   
                    <td class="serviceName"><c:out value = "${curatorRecommend.curatorExtBooks[i].serviceName}"/></td>                   
                    <td><a nohref onclick="deleteExtBook('${curatorRecommend.curatorExtBooks[i].contentId}')">刪除</a></td>
                  </tr>
                     </c:forEach>
                   </c:if>
                 </tbody>
               </table>
             </div>
		</div>
		<br/><br/>
		<div class="form-group">
			<a type="button" class="btn btn-default" href="../article/list">取消</a>			
		    <input type="button" onClick="getCuratorContent(checkSubmit)()" value="儲存" class="btn btn-primary">
		</div>
	</form:form>
</div>
<div id="imageCrop" style="display:none;z-index:1000;background:gainsboro;position:fixed;left:50%;top:10%;min-width:350px;min-height:200px;transform:translateX(-50%)">
    <div style="background:black;color:white;height:30px;padding-left:10px;padding-top:5px;margin-bottom:10px;">剪裁</div>
    <div style="margin:0 5%">
	    <label>長 <input type="text" size="1" id="cropW"/></label>
		<label> 寬 <input type="text" size="1" id="cropH"/></label>
		<input id="applyCrop" type="button" class="btn btn-info" style="margin-left:10%;" value="套用">		
		<input id="closeCrop" type="button" class="btn btn-info" style="margin-left:2%;" value="關閉">		
	</div>
	<div id="cropCanvas" style="margin-top:5px;"></div>
	<div id="titleExend" style="display:none;position:absolute;left:99%;top:0px;width: 105px;height:30px;background: black;"></div>
	<div id="images" style="position:absolute;left:100%;top:30px;width:100px;height:90%;overflow: auto;background:white"></div>
</div>	
</body>
</html>
