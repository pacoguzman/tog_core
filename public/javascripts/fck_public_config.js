// CHANGE FOR APPS HOSTED IN SUBDIRECTORY
FCKRelativePath = '';

// DON'T CHANGE THESE
FCKConfig.LinkBrowserURL = FCKConfig.BasePath + 'filemanager/browser/default/browser.html?Connector='+FCKRelativePath+'/fckeditor/command';
FCKConfig.ImageBrowserURL = FCKConfig.BasePath + 'filemanager/browser/default/browser.html?Type=images&Connector='+FCKRelativePath+'/fckeditor/command';
FCKConfig.FlashBrowserURL = FCKConfig.BasePath + 'filemanager/browser/default/browser.html?Type=flash&Connector='+FCKRelativePath+'/fckeditor/command';

FCKConfig.LinkUploadURL = FCKRelativePath+'/fckeditor/upload';
FCKConfig.ImageUploadURL = FCKRelativePath+'/fckeditor/upload?Type=images';
FCKConfig.FlashUploadURL = FCKRelativePath+'/fckeditor/upload?Type=flash';
FCKConfig.AllowQueryStringDebug = false;
FCKConfig.SpellChecker = 'SpellerPages';

// ONLY CHANGE BELOW HERE
FCKConfig.SkinPath = FCKConfig.BasePath + 'skins/silver/';

FCKConfig.ToolbarSets["Basic"] = [
	['Cut','Copy','Paste','Undo','Bold','Italic','Underline',
	'UnorderedList','-','Link','Unlink']	
] ;

FCKConfig.AutoDetectLanguage = false ;
FCKConfig.DefaultLanguage = "en" ;
FCKConfig.TemplateReplaceAll = false ;

FCKConfig.ProcessHTMLEntities	= true ;
FCKConfig.IncludeLatinEntities	= false ;
FCKConfig.IncludeGreekEntities	= false ;

FCKConfig.EnterMode = 'br' ;			// p | div | br
FCKConfig.ShiftEnterMode = 'p' ;	// p | div | br

FCKConfig.DisableObjectResizing = true ;

FCKConfig.ImageDlgHideLink		= true ;
FCKConfig.ImageDlgHideAdvanced	= true ;

FCKConfig.LinkDlgHideTarget	= true ;
FCKConfig.LinkDlgHideAdvanced	= true ;

FCKConfig.ImageUpload = false ;
FCKConfig.FlashUpload = false ;
FCKConfig.LinkUpload = false ;

FCKConfig.ImageBrowser = false ;
FCKConfig.FlashBrowser = false ;
FCKConfig.LinkBrowser = false ;

FCKConfig.AutoDetectPasteFromWord = true ;
FCKConfig.CleanWordKeepsStructure = false ;
FCKConfig.ForcePasteAsPlainText = true ;

FCKConfig.DocType = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' ;

FCKConfig.ToolbarCanCollapse = false;
