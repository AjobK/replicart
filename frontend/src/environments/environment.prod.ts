import { HttpHeaders } from "@angular/common/http";

export const environment = {
  production: true,
  API_URL: window.location.origin + ':8080',
  DEFAULT_HTTP_OPTIONS: {
    headers: new HttpHeaders({ 'Content-Type': 'application/json' }),
    
    withCredentials: true, 
    observe: 'response' as 'response'
  }
};