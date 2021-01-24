import { HttpHeaders } from "@angular/common/http";

export const environment = {
  production: true,
  API_URL: 'http://188.166.93.249:8080',
  DEFAULT_HTTP_OPTIONS: {
    headers: new HttpHeaders({ 'Content-Type': 'application/json' }),
    
    withCredentials: true, 
    observe: 'response' as 'response'
  }
};