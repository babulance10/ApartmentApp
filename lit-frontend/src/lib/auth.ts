export function getUser() {
  const u = localStorage.getItem('user');
  return u ? JSON.parse(u) : null;
}

export function getToken() {
  return localStorage.getItem('token');
}

export function setAuth(token: string, user: any) {
  localStorage.setItem('token', token);
  localStorage.setItem('user', JSON.stringify(user));
}

export function clearAuth() {
  localStorage.removeItem('token');
  localStorage.removeItem('user');
}

export function isAdmin(user: any) {
  return user?.role === 'ADMIN';
}

export function isOwner(user: any) {
  return user?.role === 'OWNER' || user?.role === 'ADMIN';
}
