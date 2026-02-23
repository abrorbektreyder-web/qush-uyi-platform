import React, { useState } from 'react';
import { Shield, Key, Eye, EyeOff } from 'lucide-react';

export const Login = ({ onLogin }: { onLogin: () => void }) => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [showPassword, setShowPassword] = useState(false);
    const [isLoading, setIsLoading] = useState(false);

    const handleLogin = (e: React.FormEvent) => {
        e.preventDefault();
        setIsLoading(true);
        setError('');

        // Mock verification
        setTimeout(() => {
            if (username === 'admin' && password === 'admin123') {
                localStorage.setItem('admin_auth', 'true');
                onLogin();
            } else {
                setError("Login yoki parol noto'g'ri. Tizimga kirish uchun: admin / admin123");
                setIsLoading(false);
            }
        }, 800);
    };

    return (
        <div style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            minHeight: '100vh',
            background: 'var(--bg-main)',
        }}>
            <div className="glass-panel" style={{ width: '100%', maxWidth: '400px', padding: '40px', animation: 'slideUp 0.4s ease' }}>
                <div style={{ textAlign: 'center', marginBottom: '32px' }}>
                    <Shield size={48} color="var(--primary)" style={{ marginBottom: '16px' }} />
                    <h1 style={{ margin: 0 }}>QUSH UYI</h1>
                    <p style={{ color: 'var(--text-muted)', margin: '8px 0 0 0' }}>Admin Portal 2.0</p>
                </div>

                {error && (
                    <div style={{ background: 'rgba(255, 73, 73, 0.1)', color: 'var(--danger)', padding: '12px', borderRadius: '8px', marginBottom: '24px', fontSize: '0.9rem', textAlign: 'center' }}>
                        {error}
                    </div>
                )}

                <form onSubmit={handleLogin}>
                    <div style={{ marginBottom: '16px' }}>
                        <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-muted)' }}>Log (Foydalanuvchi nomi)</label>
                        <input
                            type="text"
                            value={username}
                            onChange={e => setUsername(e.target.value)}
                            style={inputStyle}
                            placeholder="Masalan: admin"
                            required
                        />
                    </div>

                    <div style={{ marginBottom: '24px', position: 'relative' }}>
                        <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-muted)' }}>Parol</label>
                        <div style={{ display: 'flex', alignItems: 'center', background: 'rgba(0,0,0,0.2)', border: '1px solid var(--border-glass)', borderRadius: '8px' }}>
                            <input
                                type={showPassword ? "text" : "password"}
                                value={password}
                                onChange={e => setPassword(e.target.value)}
                                style={{ ...inputStyle, border: 'none', background: 'transparent' }}
                                placeholder="******"
                                required
                            />
                            <button
                                type="button"
                                onClick={() => setShowPassword(!showPassword)}
                                style={{ background: 'transparent', border: 'none', color: 'var(--text-muted)', padding: '0 16px', cursor: 'pointer' }}
                            >
                                {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                            </button>
                        </div>
                    </div>

                    <button type="submit" className="btn btn-primary" style={{ width: '100%', padding: '14px', fontSize: '1.1rem' }} disabled={isLoading}>
                        {isLoading ? "Tekshirilmoqda..." : <span style={{ display: 'flex', alignItems: 'center', gap: '8px', justifyContent: 'center' }}><Key size={20} /> Tizimga Kirish</span>}
                    </button>
                </form>
            </div>
        </div>
    );
};

const inputStyle = {
    width: '100%',
    padding: '12px 16px',
    borderRadius: '8px',
    background: 'rgba(0,0,0,0.2)',
    border: '1px solid var(--border-glass)',
    color: 'white',
    outline: 'none',
    fontSize: '1rem',
};
