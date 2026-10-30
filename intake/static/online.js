'use strict';
// Reuse the canonical form renderer and collect(); keep offline export available.
document.querySelector('h1').textContent='Secure setup intake';
document.querySelector('h1 + p').textContent='Submit setup choices to your organization’s private intake service. This does not provision accounts or deploy the HR app.';
document.querySelector('.notice').textContent='Online mode: submissions are stored privately for the configured retention period. Do not enter passwords, API keys, tokens, connection strings, private access links or employee records. Credentials go in your organization’s secret manager.';
document.getElementById('acknowledge-help').textContent='Review every answer for secrets and employee records, then submit securely here. Credentials must be supplied separately through your secret manager.';
const submitButton=document.querySelector('button[type=submit]');
submitButton.textContent='Submit securely';
const dashboard=document.createElement('section');
dashboard.setAttribute('aria-label','Your submissions');
const heading=document.createElement('h2');heading.textContent='Your submissions';dashboard.append(heading);
const list=document.createElement('ul');dashboard.append(list);document.querySelector('main').prepend(dashboard);
let csrf='';
async function api(path,options={}){
 const response=await fetch(path,{credentials:'same-origin',...options});
 const data=await response.json();
 if(!response.ok)throw Error((data.errors||[data.error||'Request failed']).join('; '));
 return data;
}
async function refresh(){
 const data=await api('/api/submissions');list.replaceChildren();
 for(const row of data.submissions){
  const item=document.createElement('li'),link=document.createElement('a');
  link.href='/api/submissions/'+row.id+'/export';link.textContent=row.id+' — '+row.status+' — download JSON';item.append(link);
  const remove=document.createElement('button');remove.type='button';remove.textContent='Delete';
  remove.onclick=async()=>{if(!confirm('Delete this submission? This cannot be undone in the active database.'))return;try{await api('/api/submissions/'+row.id+'/delete',{method:'POST',headers:{'X-CSRF-Token':csrf}});await refresh();}catch(e){status.textContent=e.message;}};
  item.append(remove);list.append(item);
 }
 if(!data.submissions.length){const item=document.createElement('li');item.textContent='No active submissions yet.';list.append(item);}
}
const ready=api('/api/session').then(async data=>{
 csrf=data.csrf;
 document.querySelector('.notice').append(' Responses expire '+data.retention_days+' days after receipt.');
 if(data.operator){const link=document.createElement('a');link.href='/operator';link.textContent='Operator review';dashboard.prepend(link);}
 const logout=document.createElement('button');logout.type='button';logout.textContent='Sign out';logout.onclick=async()=>{await fetch('/logout',{method:'POST',headers:{'X-CSRF-Token':csrf},credentials:'same-origin'});location.assign('/');};dashboard.append(logout);
 await refresh();
}).catch(e=>{status.textContent=e.message;});
form.addEventListener('submit',async event=>{
 event.preventDefault();event.stopImmediatePropagation();
 if(!form.reportValidity())return;
 const data=collect();
 if(unsafe(data)){status.textContent='Remove credential-like values before submitting.';return;}
 submitButton.disabled=true;status.textContent='Submitting…';
 try{
  await ready;
  if(!csrf)throw Error('Sign in again before submitting.');
  const receipt=await api('/api/submissions',{method:'POST',headers:{'Content-Type':'application/json','X-CSRF-Token':csrf},body:JSON.stringify(data)});
  status.textContent='Saved. Receipt: '+receipt.id+'. No accounts have been provisioned. Your setup operator can review and export this response.';
  await refresh();
 }catch(e){status.textContent=e.message;}finally{submitButton.disabled=false;}
},true);
