// scripts/auth.js (demo only; client-side storage)
(function (global) {
  const STORAGE_KEY = 'acme_demo_v2';
  const DEFAULT = {
    role: '', // 'owner' | 'follower'
    ownerEmail: 'owner@example.com',
    ownerPassword: 'ownerpass',
    followers: [] // [{ email: 'user@example.com', password: 'pw' }]
  };

  // ... (rest of file)

  function read() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(DEFAULT));
        return Object.assign({}, DEFAULT);
      }
      const data = Object.assign({}, DEFAULT, JSON.parse(raw));
      // migrate old followers array of strings to objects
      if (Array.isArray(data.followers) && data.followers.length && typeof data.followers[0] === 'string') {
        data.followers = data.followers.map(e => ({ email: e, password: '' }));
      }
      return data;
    } catch (e) {
      return Object.assign({}, DEFAULT);
    }
  }

  function write(data) {
    try { localStorage.setItem(STORAGE_KEY, JSON.stringify(data)); } catch (e) { /* ignore */ }
  }

  const Auth = {
    loginOwner(email, password) {
      const s = read();
      if (email.toLowerCase() === (s.ownerEmail || '').toLowerCase() && password === (s.ownerPassword || '')) {
        s.role = 'owner';
        write(s);
        return true;
      }
      return false;
    },
    isOwner() {
      const s = read();
      return s.role === 'owner';
    },
    signOut() {
      const s = read();
      s.role = '';
      write(s);
    },
    // Add follower with password (required)
    addFollower(email, password) {
      if (!email || !password) return;
      const s = read();
      const e = email.toLowerCase();
      const found = (s.followers || []).find(f => f.email === e);
      if (found) {
        // update password if provided
        found.password = password;
      } else {
        s.followers = s.followers || [];
        s.followers.push({ email: e, password });
      }
      s.role = 'follower';
      write(s);
    },
    // Login follower with email+password
    loginFollower(email, password) {
      if (!email || !password) return false;
      const s = read();
      const e = email.toLowerCase();
      const found = (s.followers || []).find(f => f.email === e && f.password === password);
      if (found) {
        s.role = 'follower';
        write(s);
        return true;
      }
      return false;
    },
    getFollowers() {
      const s = read();
      return (s.followers || []).map(f => f.email);
    }
  };

  global.Auth = Auth;
})(window);