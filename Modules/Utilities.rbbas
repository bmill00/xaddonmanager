#tag ModuleProtected Module Utilities	#tag Method, Flags = &h0		Sub deleteContentsOfFolder(folder as FolderItem)		  // Code from http://ramblings.aaronballman.com/2005/04/How_to_Delete_a_Folder.html		  		  dim i, count as Integer		  count = folder.Count		  		  for i = 1 to count // Check to see if the item is a directory		    if folder.TrueItem( 1 ).Directory then		      deleteContentsOfFolder( folder.TrueItem(1) )		    end if		    folder.TrueItem( 1 ).Delete		  next i		  		End Sub	#tag EndMethod	#tag Method, Flags = &h0		Function normaliseFilePath(filePath as String) As String		  #if TargetMacOS		    return filePath.replaceAll(":", "/")		  #elseif TargetWin32		    return filePath.replaceAll("\", "/")		  #else		    return filePath		  #endif		  		End Function	#tag EndMethod	#tag Method, Flags = &h0		Function binToHex(binaryString as string, separator as string = " ") As string		  dim result as string		  dim i as integer		  		  result = ""		  For i = 1 to LenB(binaryString)		    result = result + Right("0" + Hex(Asc(MidB(binaryString, i, 1))), 2) + separator		  next		  		  return result		End Function	#tag EndMethod	#tag Method, Flags = &h0		Function hexToBin(hexString as String, separator as string = " ") As string		  dim result as string		  dim i as integer		  dim characterLength as integer		  		  characterLength = len(separator) + 2		  		  result = ""		  for i = 1 to Len(hexString) step characterLength		    result = result + Chr(Val("&h" + MidB(hexString, i, 2)))		  next		  		  return result		End Function	#tag EndMethod	#tag Method, Flags = &h0		Sub traverseFolderStructure(callbackClass as FolderTraversalCallbackInterface, folderItem as FolderItem, callbackForFiles as boolean, callbackForFolders as boolean, data as variant)		  dim i, count as Integer		  count = folderItem.Count		  		  for i = 1 to count		    // Check to see if the item is a directory		    if folderItem.trueItem(i).Directory then		      if callbackForFolders then		        callbackClass.folderTraversalCallback(folderItem.trueItem(i), data)		      end if		      // Recurse		      traverseFolderStructure(callbackClass, folderItem.trueItem(i), callbackForFiles, callbackForFolders, data)		    else		      if callbackForFiles then		        callbackClass.folderTraversalCallback(folderItem.trueItem(i), data)		      end if		    end if		  next i		  		End Sub	#tag EndMethod	#tag Method, Flags = &h0		Function isUserLocalAdministrator() As Boolean		  // Copyright © Aaron Ballman		  // Code from: http://ramblings.aaronballman.com/2006/10/Is_the_user_an_administrator.html		  		  #if TargetMacOS or TargetLinux		    return true		  #endif		  		  dim fReturn as Boolean = false		  dim dwStatus, dwAccessMask, dwAccessDesired, dwACLSize as Integer		  dim dwStructureSize as Integer = 20 'sizeof(PRIVILEGE_SET)		  dim pACL, psidAdmin as Integer		  dim hToken as Integer		  dim hImpersonationToken as Integer		  dim ps as new MemoryBlock( dwStructureSize )		  dim GenericMapping as new MemoryBlock( 16 )		  dim psdAdmin as Integer		  dim SystemSidAuthority as new MemoryBlock( 6 )		  		  SystemSidAuthority.Byte( 0 ) = 0		  SystemSidAuthority.Byte( 1 ) = 0		  SystemSidAuthority.Byte( 2 ) = 0		  SystemSidAuthority.Byte( 3 ) = 0		  SystemSidAuthority.Byte( 4 ) = 0		  SystemSidAuthority.Byte( 5 ) = 5		  		  		  // Determine if the current thread is running as a user that is a member		  // of the local admins group. To do this, create a security descriptor		  // that has a DACL which has an ACE that allows only local aministrators		  // access. Then, call AccessCheck with the current thread's token and the		  // security descriptor. It will say whether the user could access an object if		  // it had that security descriptor. Note: you do not need to actually		  // create the object. Just checking access against the security descriptor		  // alone will be sufficient.		  		  // AccessCheck() requires an impersonation token. We first get a		  // primary token and then create a duplicate impersonation token. The		  // impersonation token is not actually assigned to the thread, but is		  // used in the call to AccessCheck. Thus, this function itself never		  // impersonates, but does use the identity of the thread. If the		  // thread was impersonating already, this function uses that impersonation		  // context.		  		  Soft Declare Function GetCurrentThread Lib "Kernel32" () as Integer		  Soft Declare Function OpenThreadToken Lib "Advapi32" ( handle as Integer, access as Integer, _		  openAsSelf as Boolean, ByRef tokenHandle as Integer ) as Boolean		  Soft Declare Function GetLastError Lib "Kernel32" () as Integer		  Soft Declare Function OpenProcessToken Lib "Advapi32" ( handle as Integer, access as Integer, _		  ByRef tokenHandle as Integer ) as Boolean		  Soft Declare Function GetCurrentProcess Lib "Kernel32" () as Integer		  Soft Declare Function DuplicateToken Lib "Advapi32" ( existing as Integer, impersination as Integer, _		  ByRef dupe as Integer ) as Boolean		  Soft Declare Function AllocateAndInitializeSid Lib "Advapi32" ( authority as Ptr, count as Byte, _		  auth0 as Integer, auth1 as Integer, auth2 as Integer, auth3 as Integer, auth4 as Integer, _		  auth5 as Integer, auth6 as Integer, auth7 as Integer, ByRef sid as Integer ) as Boolean		  Soft Declare Function LocalAlloc Lib "Kernel32" ( flags as Integer, bytes as Integer ) as Integer		  Soft Declare Function InitializeSecurityDescriptor Lib "AdvApi32" ( desc as Integer, revision as Integer ) as Boolean		  Soft Declare Function GetLengthSid Lib "AdvApi32" ( sid as Integer ) as Integer		  Soft Declare Function InitializeAcl Lib "AdvApi32" ( acl as Integer, length as Integer, revision as Integer ) as Boolean		  Soft Declare Function AddAccessAllowedAce Lib "AdvApi32" ( acl as Integer, revision as Integer, access as Integer, sid as Integer ) as Boolean		  Soft Declare Function SetSecurityDescriptorDacl Lib "AdvApi32" ( desc as Integer, daclPresent as Boolean, _		  dacl as Integer, defaulted as Boolean ) as Boolean		  Soft Declare Sub SetSecurityDescriptorGroup Lib "AdvApi32" ( desc as Integer, group as Integer, defaulted as Boolean )		  Soft Declare Sub SetSecurityDescriptorOwner Lib "AdvApi32" ( desc as Integer, owner as Integer, defaulted as Boolean )		  Soft Declare Function IsValidSecurityDescriptor Lib "AdvApi32" ( desc as Integer ) as Boolean		  Soft Declare Function AccessCheck Lib "AdvApi32" ( desc as Integer, client as Integer, access as Integer, mapping as Ptr, _		  privSet as Ptr, ByRef privSetLength as Integer, ByRef grantedAccess as Integer, ByRef accessStatus as Integer ) as Boolean		  Soft Declare Sub LocalFree Lib "Kernel32" ( p as Integer )		  Soft Declare Sub CloseHandle Lib "Kernel32" ( handle as Integer )		  Soft Declare Sub FreeSid Lib "AdvApi32" ( sid as Integer )		  		  Const TOKEN_DUPLICATE = &h2		  Const TOKEN_QUERY = &h8		  Const ERROR_NO_TOKEN = 1008		  		  if not OpenThreadToken( GetCurrentThread(), TOKEN_DUPLICATE + TOKEN_QUERY, true, hToken ) then		    if not OpenProcessToken( GetCurrentProcess(), TOKEN_DUPLICATE + TOKEN_QUERY, hToken ) then		      goto cleanup		    end if		  end if		  		  Const SecurityImpersonation = 2		  if not DuplicateToken ( hToken, SecurityImpersonation, hImpersonationToken ) then		    goto cleanup		  end if		  		  // Create the binary representation of the well-known SID that		  // represents the local administrators group. Then create the		  // security descriptor and DACL with an ACE that allows only local admins		  // access. After that, perform the access check. This will determine whether		  // the current user is a local admin.		  Const SECURITY_BUILTIN_DOMAIN_RID = &h20		  Const DOMAIN_ALIAS_RID_ADMINS = &h220		  if not AllocateAndInitializeSid( SystemSidAuthority, 2, SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS, 0, 0, 0, 0, 0, 0, psidAdmin ) then		    goto cleanup		  end if		  		  Const LPTR = &h40		  Const SECURITY_DESCRIPTOR_MIN_LENGTH = 20		  psdAdmin = LocalAlloc( LPTR, SECURITY_DESCRIPTOR_MIN_LENGTH )		  if psdAdmin = 0 then		    goto cleanup		  end if		  		  Const SECURITY_DESCRIPTOR_REVISION = 1		  if not InitializeSecurityDescriptor( psdAdmin, SECURITY_DESCRIPTOR_REVISION ) then		    goto cleanup		  end if		  		  // Compute size needed for the ACL.		  dwACLSize = 8 + 16 + GetLengthSid( psidAdmin ) - 4		  		  pACL = LocalAlloc( LPTR, dwACLSize )		  if pACL = 0 then		    goto cleanup		  end if		  		  Const ACL_REVISION2 = 2		  if not InitializeAcl( pACL, dwACLSize, ACL_REVISION2 ) then		    goto cleanup		  end if		  		  Const ACCESS_READ = &h1		  Const ACCESS_WRITE = &h2		  dwAccessMask= ACCESS_READ + ACCESS_WRITE		  		  if not AddAccessAllowedAce( pACL, ACL_REVISION2, dwAccessMask, psidAdmin ) then		    goto cleanup		  end if		  		  if not SetSecurityDescriptorDacl( psdAdmin, true, pACL, false ) then		    goto cleanup		  end if		  		  // AccessCheck validates a security descriptor somewhat; set the		  // group and owner so that enough of the security descriptor is filled out		  // to make AccessCheck happy.		  		  SetSecurityDescriptorGroup( psdAdmin, psidAdmin, false )		  SetSecurityDescriptorOwner( psdAdmin, psidAdmin, false )		  		  if not IsValidSecurityDescriptor( psdAdmin ) then		    goto cleanup		  end if		  		  dwAccessDesired = ACCESS_READ		  		  // Initialize GenericMapping structure even though you		  // do not use generic rights.		  GenericMapping.Long( 0 ) = ACCESS_READ		  GenericMapping.Long( 4 ) = ACCESS_WRITE		  GenericMapping.Long( 8 ) = 0		  GenericMapping.Long( 12 ) = ACCESS_READ + ACCESS_WRITE		  		  dim ret as Integer		  if not AccessCheck( psdAdmin, hImpersonationToken, dwAccessDesired, GenericMapping, ps, dwStructureSize, dwStatus, ret ) then		    dim err as Integer = GetLastError		    		    fReturn = false		    goto cleanup		  end if		  		  fReturn = ret <> 0		  		  cleanup:		  // Clean up.		  if pACL <> 0 then LocalFree( pACL )		  if psdAdmin <> 0 then LocalFree( psdAdmin )		  if psidAdmin <> 0 then FreeSid( psidAdmin )		  if hImpersonationToken <> 0 then CloseHandle( hImpersonationToken )		  if hToken <> 0 then CloseHandle( hToken )		  		  return fReturn		  		exception e as FunctionNotFoundException		  return true		  		End Function	#tag EndMethod	#tag Method, Flags = &h0		Sub reRunAsAdministrator()		  // Copyright © Aaron Ballman		  // Code from: http://ramblings.aaronballman.com/2007/03/uac_and_you.html		  		  #if TargetMacOS or TargetLinux		    return		  #endif		  		  Soft Declare Function ShellExecuteExW Lib "Shell32" ( info as Ptr ) as Boolean		  Soft Declare Function ShellExecuteExA Lib "Shell32" ( info as Ptr ) as Boolean		  		  dim info as new MemoryBlock( 15 * 4 )		  dim verb as new MemoryBlock( 32 )		  dim file as new MemoryBlock( 260 * 2 )		  		  info.Long( 0 ) = info.Size		  //info.Long( 8 ) = wndMain.Handle		  		  if System.IsFunctionAvailable( "ShellExecuteExW", "Shell32" ) then		    verb.WString( 0 ) = "runas"		    file.WString( 0 ) = App.ExecutableFile().AbsolutePath()		  else		    verb.CString( 0 ) = "runas"		    file.CString( 0 ) = App.ExecutableFile().AbsolutePath()		  end if		  info.Ptr( 12 ) = verb		  info.Ptr( 16 ) = file		  		  Const SW_SHOWNORMAL = 1		  info.Long( 28 ) = SW_SHOWNORMAL		  		  dim ret as Boolean		  if System.IsFunctionAvailable( "ShellExecuteExW", "Shell32" ) then		    ret = ShellExecuteExW( info )		  else		    ret = ShellExecuteExA( info )		  end if		  		  quit		End Sub	#tag EndMethod	#tag ViewBehavior		#tag ViewProperty			Name="Name"			Visible=true			Group="ID"			InheritedFrom="Object"		#tag EndViewProperty		#tag ViewProperty			Name="Index"			Visible=true			Group="ID"			InitialValue="-2147483648"			InheritedFrom="Object"		#tag EndViewProperty		#tag ViewProperty			Name="Super"			Visible=true			Group="ID"			InheritedFrom="Object"		#tag EndViewProperty		#tag ViewProperty			Name="Left"			Visible=true			Group="Position"			InitialValue="0"			InheritedFrom="Object"		#tag EndViewProperty		#tag ViewProperty			Name="Top"			Visible=true			Group="Position"			InitialValue="0"			InheritedFrom="Object"		#tag EndViewProperty	#tag EndViewBehaviorEnd Module#tag EndModule