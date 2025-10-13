export default function Home() {
  const loadPosts = async () => {
    try {
      const response = await fetch('http://localhost:8080/api/posts');
      const posts = await response.json();
      console.log('Posts from Go API:', posts);
      alert(`Loaded ${posts.length} posts from Go backend!`);
    } catch (error) {
      console.error('Failed to load posts:', error);
    }
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>DevOps Example Blog</h1>
      <p>Frontend (Next.js) + Backend (Go)</p>
      <button onClick={loadPosts} style={{ padding: '10px', margin: '10px' }}>
        Load Posts from Go API
      </button>
    </div>
  );
}