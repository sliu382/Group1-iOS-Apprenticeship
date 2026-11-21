//
//  PostCard.swift
//  Cosmetic-Planning-App
//

import SwiftUI

/** A post in the feed: content + like / comment / view details / save row */
struct PostCard<Detail: View>: View {
    let post: Post
    let isMine: Bool
    let onLike: () -> Void
    let onSave: () -> Void
    let onDelete: () -> Void
    @ViewBuilder let detail: () -> Detail

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            PostContent(post: post, isMine: isMine, onSave: onSave, onDelete: onDelete)

            HStack(spacing: 18) {
                LikeButton(post: post, action: onLike)

                NavigationLink {
                    detail()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 18))
                        Text("\(post.commentCount)")
                            .font(.appSans(12))
                    }
                    .foregroundStyle(AppColor.muted)
                }

                NavigationLink {
                    detail()
                } label: {
                    Text("View details")
                        .font(.appSans(11, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x8E657A))
                }

                Spacer()

                SaveButton(post: post, action: onSave)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .modifier(RectangularCard(radius: 24))
    }
}

/** Author, tag, title, text, and the routine steps or product box */
struct PostContent: View {
    let post: Post
    let isMine: Bool
    let onSave: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Author row
            HStack(spacing: 12) {
                AuthorAvatar(name: post.authorName, id: post.userId, size: 46)
                VStack(alignment: .leading, spacing: 3) {
                    Text(post.authorName)
                        .font(.appSans(14, weight: .semibold))
                        .foregroundStyle(AppColor.ink)
                    Text("@\(post.authorUsername) · \(post.createdAt.shortTimeAgo)")
                        .font(.appSans(10))
                        .foregroundStyle(AppColor.muted)
                }
                Spacer()
                Menu {
                    Button(post.savedByMe ? "Remove from saved" : "Save post",
                           systemImage: post.savedByMe ? "bookmark.slash" : "bookmark",
                           action: onSave)
                    if isMine {
                        Button("Delete post", systemImage: "trash", role: .destructive, action: onDelete)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15))
                        .foregroundStyle(AppColor.muted)
                        .frame(width: 32, height: 32)
                }
            }

            // "SKINCARE · ROUTINE"
            Text(post.tag)
                .font(.appSans(9, weight: .semibold))
                .tracking(1)
                .foregroundStyle(post.kind == .routine ? Color(hex: 0x6B5F86) : Color(hex: 0xA0614A))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(post.kind == .routine ? AppColor.lilac.opacity(0.6) : AppColor.peach.opacity(0.6),
                            in: Capsule())

            VStack(alignment: .leading, spacing: 6) {
                Text(post.title)
                    .font(.appSerif(24))
                    .foregroundStyle(AppColor.ink)
                if let body = post.body, !body.isEmpty {
                    Text(body)
                        .font(.appSans(12))
                        .foregroundStyle(AppColor.muted)
                        .lineSpacing(3)
                }
            }

            switch post.kind {
            case .routine: routineBox
            case .recommendation: productBox
            }
        }
    }

    /** "MY ROUTINE · 3 STEPS" with numbered steps */
    private var routineBox: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My routine · \(post.stepTitles.count) step\(post.stepTitles.count == 1 ? "" : "s")".uppercased())
                .font(.appSans(9))
                .tracking(0.8)
                .foregroundStyle(Color(hex: 0x8E657A))
            if post.stepTitles.isEmpty {
                Text("No steps added yet")
                    .font(.appSans(11))
                    .foregroundStyle(AppColor.muted)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: 3),
                          alignment: .leading, spacing: 10) {
                    ForEach(Array(post.stepTitles.enumerated()), id: \.offset) { index, step in
                        HStack(spacing: 7) {
                            Text("\(index + 1)")
                                .font(.appSerif(11))
                                .foregroundStyle(AppColor.ink)
                                .frame(width: 22, height: 22)
                                .background(AppColor.rose.opacity(0.6), in: Circle())
                            Text(step)
                                .font(.appSans(10))
                                .foregroundStyle(AppColor.ink)
                                .lineLimit(2)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(hex: 0xF5F2F8), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AppColor.line, lineWidth: 1)
        }
    }

    /** "PRODUCT RECOMMENDATION — Mallow Petal Tint Balm · $22" */
    private var productBox: some View {
        HStack(spacing: 14) {
            Image(systemName: "bag")
                .font(.system(size: 18))
                .foregroundStyle(Color(hex: 0xA0614A))
                .frame(width: 46, height: 46)
                .background(AppColor.peach.opacity(0.7), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text("PRODUCT RECOMMENDATION")
                    .font(.appSans(9))
                    .tracking(0.8)
                    .foregroundStyle(Color(hex: 0xA0614A))
                Text(post.productLine)
                    .font(.appSans(12, weight: .semibold))
                    .foregroundStyle(AppColor.ink)
            }
            Spacer()
        }
        .padding(12)
        .background(Color(hex: 0xFAF0EE), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AppColor.line, lineWidth: 1)
        }
    }
}

/** Circle with initials; color is picked from the user id so it stays the same */
struct AuthorAvatar: View {
    let name: String
    let id: UUID
    var size: CGFloat = 46

    private static let colors: [UInt] = [0xA57A8E, 0x7C7299, 0x7E8C7A, 0xB08872, 0x8E6F86]

    var body: some View {
        let index = Int(id.uuid.0) % Self.colors.count
        Text(Post.initials(for: name))
            .font(.appSerif(size * 0.36))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Color(hex: Self.colors[index]), in: Circle())
    }
}

struct LikeButton: View {
    let post: Post
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: post.likedByMe ? "heart.fill" : "heart")
                    .font(.system(size: 19))
                    .contentTransition(.symbolEffect(.replace))
                Text("\(post.likeCount)")
                    .font(.appSans(12))
            }
            .foregroundStyle(post.likedByMe ? Color(hex: 0x9E5C72) : AppColor.muted)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: post.likedByMe)
    }
}

struct SaveButton: View {
    let post: Post
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: post.savedByMe ? "bookmark.fill" : "bookmark")
                .font(.system(size: 19))
                .foregroundStyle(post.savedByMe ? AppColor.accent : AppColor.muted)
        }
        .buttonStyle(.plain)
    }
}
